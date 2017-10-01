#const Nc#

mdp

// constants for the configuration of the model
const bool synth_schedule = false;   // ask prism to syntesize the best scheduler (the one that minimizes dropped frames - weighted)
const bool event = true;             // shall this run event based (alternative is periodic invocation)
const double threshold_event;  // used to determine if the resource manager should be invoked, ignored if event = false

// constants for property assessment
const int penalty_frames = 10;
const int penalty_intervention = 1;

// constants for the simulation
const int num_cameras = #Nc#;         // number of cameras
const int round_millis = 30;          // round duration in milliseconds
const int bytes_millis = 4194;        // number of bytes that can be sent per millisecond (total bw is 4Mbytes per sec)
const int max_frames;                 // determines the length of the simualtion - X frames per camera
const int minimum_framesize = 64;     // a frame occupies a minimum of X bytes
const int maximum_framesize = 100000; // a frame occupies a maximum of X bytes
const int sche = 0;                   // used to model the turns: scheduler -> (maybe)rm -> cam1 -> cam2 -> .. -> camN
const int rmng = 1;                   // used to model the turns: scheduler -> (maybe)rm -> cam1 -> cam2 -> .. -> camN
#for i=1:Nc#
const int cam#i# = 1+#i#;             // used to model the turns: scheduler -> (maybe)rm -> cam1 -> cam2 -> .. -> camN
#end#
#for i=1:Nc#
const double lambda#i# = 0.5;         // used by the resource manager to discriminate between cameras [0..1]
#end#

// global variables
global rounds: int init 0;              // count the number of rounds in total
global turn: [sche..cam#Nc#] init sche; // detrmines the current executing entity 
global want_rm: bool init true;         // should the bandwidth be allocated

// used to assess in properties if things are changing, need to be global to be reset by the scheduler
global rmchange: bool init false;
#for i=1:Nc#
global c#i#change: bool init false;
#end#

// POTENTIAL IMPROVEMENT: this part should eventually be substituted with either-or
//       (1) stochastic disturbance based on some observation
//       (2) precise model based on encoding technique and parameters like amount of nature and light
// for now this is just a very simple model of the frame size, which has saturation levels but is linear wrt quality
// ******************** FRAME SIZE COMPUTATION (INI) ********************
#for i=1:Nc#
formula framesize#i# = min(maximum_framesize, max(minimum_framesize, ceil(q#i# * maximum_framesize / 100)));
#end#
// ******************** FRAME SIZE COMPUTATION (FIN) ********************

// ******************** TIMES COMPUTATION (INI) ********************
#for i=1:Nc-1#
formula t#i# = floor(round_millis * bw#i# / 100); // time assigned in slot for camera #i# in milliseconds
formula compute_tn#i# = ceil(framesize#i# / bytes_millis); // time in millis needed to transmit frame of camera #i#
#end#
formula t#Nc# = ceil(round_millis * bw#Nc# / 100);  // time assigned in slot for camera #Nc# in milliseconds
formula compute_tn#Nc# = ceil(framesize#Nc# / bytes_millis); // time in millis needed to transmit frame of camera #Nc#
// ******************** TIMES COMPUTATION (FIN) ********************

// ******************** CONTROL AT THE CAMERA LEVEL (INI) ********************
// control parameters for the camera quality adaptation (integral controller)
#for i=1:Nc#
const double k#i# = 5.0;
#end#
const int minimum_quality = 15;
const int maximum_quality = 85;
// compute errors as: (time assigned in slot - time needed in slot) / (time assigned in slot)
#for i=1:Nc#
formula f#i# = (t#i# - compute_tn#i#) / t#i#; // matching function camera #i#
#end#
// control actions
#for i=1:Nc#
formula update_q#i# = max(minimum_quality, min(maximum_quality, floor(q#i# + k#i# * f#i#)));
#end#
// ******************** CONTROL AT THE CAMERA LEVEL (FIN) ********************

// ******************** CONTROL AT THE NETWORK MANAGER LEVEL (INI) ********************
const double eps = 0.4;
const int minimum_bw = 1;
const int maximum_bw = 100;
formula sum_lambdaf = (#for i=1:Nc-1#lambda#i# * f#i# +#end# lambda#Nc# * f#Nc#);
#for i=1:Nc-1#
formula update_bw#i# = max(minimum_bw, min(maximum_bw, floor(100 * (bw#i#/100 + eps * (-lambda#i# * f#i# + sum_lambdaf * bw#i#/100)))));
#end#
formula update_bw#Nc# = 100#for i=1:Nc-1# - update_bw#i##end#;  // camera #Nc# gets the remaining percentage, NOTE: improtant update_bw1 and not bw1 
// ******************** CONTROL AT THE NETWORK MANAGER LEVEL (FIN) ********************

module scheduler
  choice_done: bool init false;
  calling_rm: bool init false;

  // Decision for synthesis of best strategy
  [best_dont] (synth_schedule) & (turn = sche) & (rounds < max_frames) & (!choice_done) -> (calling_rm' = false) & (choice_done' = true);
  [best_do] (synth_schedule) & (turn = sche) & (rounds < max_frames) & (!choice_done) -> (calling_rm' = true) & (choice_done' = true);

  // Decision without synthesis
  [decision] (!synth_schedule) & (turn = sche) & (rounds < max_frames) & (!choice_done) -> (calling_rm' = want_rm) & (choice_done' = true);
 
  [] (turn = sche) & (rounds < max_frames) & (choice_done) & (calling_rm)  -> (turn' = rmng) & (calling_rm' = false);
  [] (turn = sche) & (rounds < max_frames) & (choice_done) & (!calling_rm) -> (turn' = cam1) &
                                                                              (rounds' = rounds + 1) &
                                                                              (choice_done' = false) &
                                                                              (want_rm' = event ? false : true) & // time based acts every round_millis
                                                                              (rmchange' = false) #for i=1:Nc# & (c#i#change' = false)#end#; // reset
endmodule

module rm
  #for i=1:Nc-1#
  bw#i#: [minimum_bw..maximum_bw] init floor(maximum_bw / num_cameras);
  #end#
  bw#Nc#: [minimum_bw..maximum_bw] init ceil(maximum_bw / num_cameras);
  rm_interventions: int init 0;

  [] (turn = rmng) -> (want_rm' = false) & // I have done my job
                      (turn' = sche) & // go back to the scheduler
                      #for i=1:Nc#(bw#i#' = update_bw#i#)  & // network manager update camera #i#
                      #end#
                      (rmchange' = ((#for i=1:Nc-1# bw#i# = update_bw#i# &#end# bw#Nc# = update_bw#Nc#) ? false : true)) &
                      (rm_interventions' = rm_interventions+1);
endmodule

#for i=1:Nc-1#
module c#i#
  q#i#: [minimum_quality..maximum_quality] init maximum_quality;
  s#i#: [minimum_framesize..maximum_framesize] init maximum_framesize;
  tran#i#: int init 0; // number of frames transmitted by camera #i#
  drop#i#: int init 0; // number of frames dropped by camera #i#
  [] (turn = cam#i#) -> (turn' = cam#i#+1) & (q#i#' = update_q#i#) & (s#i#' = framesize#i#)
                    & (c#i#change' = (q#i# = update_q#i# ? false : true)) 
                    & (tran#i#' = compute_tn#i#<=t#i#? tran#i#+1: tran#i#)
                    & (drop#i#' = compute_tn#i#>t#i#? drop#i#+1: drop#i#)
                    & (want_rm' = f#i# > threshold_event | f#i# < -threshold_event ? true : want_rm);
endmodule
#end#

module c#Nc#
  q#Nc#: [minimum_quality..maximum_quality] init maximum_quality;
  s#Nc#: [minimum_framesize..maximum_framesize] init maximum_framesize;
  tran#Nc#: int init 0; // number of frames transmitted by camera #Nc#
  drop#Nc#: int init 0; // number of frames dropped by camera #Nc#
  [] (turn = cam#Nc#) -> (turn' = sche) & (q#Nc#' = update_q#Nc#) & (s#Nc#' = framesize#Nc#)
                    & (c#Nc#change' = (q#Nc# = update_q#Nc# ? false : true))
                    & (tran#Nc#' = compute_tn#Nc#<=t#Nc#? tran#Nc#+1: tran#Nc#)
                    & (drop#Nc#' = compute_tn#Nc#>t#Nc#? drop#Nc#+1: drop#Nc#)
                    & (want_rm' = f#Nc# > threshold_event | f#Nc# < -threshold_event ? true : want_rm);
endmodule


// ******************** PROPERTIES RELATED CODE (INI) ********************
label "any_change_event" = (rmchange #for i=1:Nc# | c#i#change#end#);
rewards "decision_calls"
  [decision]  true: 1;
  [best_do]   true: 1;
  [best_dont] true: 1;
endrewards
rewards "rm_calls"
  [decision]  rounds = max_frames-1: rm_interventions;
  [best_do]   rounds = max_frames-1: rm_interventions;
  [best_dont] rounds = max_frames-1: rm_interventions;
endrewards
rewards "dropped_frames"
  [decision]  rounds = max_frames-1: #for i=1:Nc-1#drop#i# +#end# drop#Nc#;
  [best_do]   rounds = max_frames-1: #for i=1:Nc-1#drop#i# +#end# drop#Nc#;
  [best_dont] rounds = max_frames-1: #for i=1:Nc-1#drop#i# +#end# drop#Nc#;
endrewards
rewards "total_cost"
  [decision]  rounds = max_frames-1: penalty_frames * (#for i=1:Nc-1#drop#i# +#end# drop#Nc#) + penalty_intervention * (rm_interventions);
  [best_do]   rounds = max_frames-1: penalty_frames * (#for i=1:Nc-1#drop#i# +#end# drop#Nc#) + penalty_intervention * (rm_interventions);
  [best_dont] rounds = max_frames-1: penalty_frames * (#for i=1:Nc-1#drop#i# +#end# drop#Nc#) + penalty_intervention * (rm_interventions);
endrewards
// ******************** PROPERTIES RELATED CODE (FIN) ********************
