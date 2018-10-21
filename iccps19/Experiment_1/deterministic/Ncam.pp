#const Nc#

smg

player manager
    rm, [man_inter], [bw_allocated], [end],

#for i=1:Nc#
    c#i# ,
#end#
    [last_cam_sent]
endplayer

// Global Variables
global want_rm: bool init true; // Global variable to indicate that manager should intervene DOESNT WORK !!!

// constants for the simulation
const int num_cameras = #Nc#; //Number of cameras
const double threshold_event = 0.2; // Threshold to trigger the manager
const int max_frames = 10; //Max number of frames
const int round_millis = 5*#Nc#;      // round duration in milliseconds
const int bytes_millis = 16776;       // number of bytes that can be sent per millisecond (total bw is 4Mbytes per sec) -- increased * 4
const int minimum_framesize = 64;     // a frame occupies a minimum of X bytes
const int maximum_framesize = 100000; // a frame occupies a maximum of X bytes
#for i=1:Nc-1#
const double lambda#i# = 0.4;         // used by the resource manager to discriminate between cameras [0..1]
#end#
const double lambda#Nc# = 0.5;  
// ******************** CONTROL AT THE NETWORK MANAGER LEVEL (INI) ********************
const int minimum_bw = 1;
const int maximum_bw = 100;
const double eps = 0.2;
formula sum_lambdaf = (#for i=1:Nc-1#lambda#i# * f#i# +#end# lambda#Nc# * f#Nc#);
#for i=1:Nc#
formula update_bw#i# = floor(max(minimum_bw, min(maximum_bw, 100 * (bw#i#/100 + eps * (-lambda#i# * f#i# + sum_lambdaf * bw#i#/100)))));
#end#
// ******************** CONTROL AT THE NETWORK MANAGER LEVEL (FIN) ********************

// ******************** TIMES COMPUTATION (INI) ********************
#for i=1:Nc-1#
formula t#i# = floor(round_millis * bw#i# / 100); // time assigned in slot for camera #i# in milliseconds
formula compute_tn#i# = ceil(framesize#i# / bytes_millis); // time in millis needed to transmit frame of camera #i#
#end#
formula t#Nc# = floor(round_millis * bw#Nc# / 100);  // time assigned in slot for camera #Nc# in milliseconds
formula compute_tn#Nc# = ceil(framesize#Nc# / bytes_millis); // time in millis needed to transmit frame of camera #Nc#
// ******************** TIMES COMPUTATION (FIN) ********************

// POTENTIAL IMPROVEMENT: this part should eventually be substituted with either-or
//       (1) stochastic disturbance based on some observation
//       (2) precise model based on encoding technique and parameters like amount of nature and light
// for now this is just a very simple model of the frame size, which has saturation levels but is linear wrt quality

// ******************** FRAME SIZE COMPUTATION (INI) ********************
#for i=1:Nc#
formula framesize#i# = min(maximum_framesize, max(minimum_framesize, ceil((q#i#) * maximum_framesize / 100)));
#end#
// ******************** FRAME SIZE COMPUTATION (FIN) ********************


const rm_init = 0;
const rm_calc_bw = 1;
const rm_alloc_bw = 2;
const rm_check_rm = 3;
const rm_end = 4;
const rm_end_final = 5;

// ******************** MANAGER MODULE (INI) ********************
module rm

rm : [rm_init..rm_end] init rm_init;
#for i=1:Nc#
  bw#i#: [minimum_bw..maximum_bw] init floor(maximum_bw / num_cameras);
#end#
frames: [0..max_frames] init 0;
end: bool init false;


[] (rm = rm_init)-> 1 : (rm' = rm_calc_bw);
[man_inter] (rm = rm_calc_bw) & (!end)-> 1 : (rm' = rm_alloc_bw) & #for i=1:Nc-1#(bw#i#' = update_bw#i#)  & #end# (bw#Nc#' = update_bw#Nc#)  & (want_rm'=false);// network manager update camera #i#
[bw_allocated] (rm = rm_alloc_bw) & (frames!=max_frames)  & (!end) -> 1 : (rm' = rm_check_rm) & (frames' = frames + 1) ;
[bw_allocated] (rm = rm_alloc_bw) & (frames>=max_frames) & (!end) -> 1 : (end' = true) ;
[end] (rm = rm_alloc_bw) & (end) -> 1 : (rm' = rm_end);
[] (rm = rm_end) -> 1: (rm' = rm_end_final);
[last_cam_sent] (rm = rm_check_rm)  & (want_rm) & (!end) -> 1 : (rm' = rm_calc_bw) ;  // No need for reconfiguration
[last_cam_sent] (rm = rm_check_rm)  & (!want_rm) & (!end)-> 1 : (rm' = rm_alloc_bw);   // Need for recalculation
//[end] (rm = rm_end) -> 1 : (rm' = rm_end); // Self absorbing final state, when frames >= max_frames

endmodule
// ******************** MANAGER MODULE (FIN) ********************

// ******************** CONTROL AT THE CAMERA LEVEL (INI) ********************
const int minimum_quality = 15;
const int maximum_quality = 85;

#for i=1:Nc#
  const double k#i# = 25;
#end#

#for i=1:Nc#
  formula f#i# = (t#i# - compute_tn#i#) / t#i#; // matching function camera #i#
#end#
// ******************** CONTROL AT THE CAMERA LEVEL (FIN) ********************

// ******************** CAMERA MODULES (INI) ********************
#for i=1:Nc-1#
  const cam#i#_init = 0;
  const cam#i#_calc_fr = 1;
  const cam#i#_fr_sent = 2;
  const cam#i#_fr_drop = 3;
  const cam#i#_thr_check = 4;
  const cam#i#_ready = 5;

module c#i#
  cam#i# : [cam#i#_init..cam#i#_ready] init cam#i#_init;

  q#i#: [minimum_quality..maximum_quality] init maximum_quality;
  old_q#i# : [minimum_quality..maximum_quality] init minimum_quality;
  q#i#_inc : [0..85] init 5;
  s#i#: [minimum_framesize..maximum_framesize] init maximum_framesize;
  e#i#: [0..100] init 1;
  alloc#i#: [0..100];
  drop#i#: [0..max_frames*2] init 0;
  sent#i#: [0..max_frames*2] init 0;

  [bw_allocated] (cam#i# = cam#i#_init)  -> 1 : (cam#i#' = cam#i#_calc_fr) ;
  [] (cam#i# = cam#i#_calc_fr) & (ceil(s#i# / bytes_millis)<= t#i#)-> 1 : (cam#i#' = cam#i#_fr_sent) & (e#i#' = t#i#) & (alloc#i#' = compute_tn#i#);
  [] (cam#i# = cam#i#_calc_fr) & (ceil(s#i# / bytes_millis) > t#i#)-> 1 : (cam#i#' = cam#i#_fr_drop) & (e#i#' = t#i#)  & (alloc#i#' = compute_tn#i#);
  [last_cam_sent] (cam#i# = cam#i#_fr_sent) -> 1 : (sent#i#'=sent#i#+1) & (cam#i#' = cam#i#_ready) & (q#i#' = q#i# + q#i#_inc)  & (old_q#i#' = q#i#); // increment the quality on succesful send and save the old quality ;
  [last_cam_sent] (cam#i# = cam#i#_fr_drop) -> 1 : (drop#i#'=drop#i#+1) & (cam#i#' = cam#i#_ready) & (q#i#' = old_q#i#) & (q#i#_inc' = floor(q#i#_inc/2)); // On frame drop, reset quality to old successful one, and reduce the increment size by 2;
  [bw_allocated] (cam#i# = cam#i#_ready) -> 1 : (cam#i#' = cam#i#_thr_check) & (s#i#'= framesize#i#);
 [] (cam#i# = cam#i#_thr_check)  & (!end) -> 1 : (cam#i#' = cam#i#_calc_fr)  & (want_rm' = (t#i# - ceil(s#i# / bytes_millis))/t#i# > threshold_event | (t#i# - ceil(s#i# /bytes_millis))/t#i# < -threshold_event ? true : want_rm = true);
endmodule
#end#

const cam#Nc#_init = 0;
const cam#Nc#_calc_fr = 1;
const cam#Nc#_fr_sent = 2;
const cam#Nc#_fr_drop = 3;
const cam#Nc#_thr_check = 4;
const cam#Nc#_ready = 5;

module c#Nc#
cam#Nc# : [cam#Nc#_init..cam#Nc#_ready] init cam#Nc#_init;

q#Nc#: [minimum_quality..maximum_quality] init maximum_quality;
old_q#Nc# : [minimum_quality..maximum_quality] init minimum_quality;
q#Nc#_inc : [0..85] init 5;
s#Nc#: [minimum_framesize..maximum_framesize] init maximum_framesize;
e#Nc#: [0..100] init 1;
alloc#Nc#: [0..100];
drop#Nc#: [0..max_frames*2] init 0;
sent#Nc#: [0..max_frames*2] init 0;

[bw_allocated] (cam#Nc# = cam#Nc#_init)  -> 1 : (cam#Nc#' = cam#Nc#_calc_fr) ;
[] (cam#Nc# = cam#Nc#_calc_fr) & (ceil(s#Nc# / bytes_millis)<= t#Nc#) -> 1 : (cam#Nc#' = cam#Nc#_fr_sent) & (e#Nc#' = t#Nc#) & (alloc#Nc#' = compute_tn#Nc#);
[] (cam#Nc# = cam#Nc#_calc_fr) & (ceil(s#Nc# / bytes_millis) > t#Nc#) -> 1 : (cam#Nc#' = cam#Nc#_fr_drop) & (e#Nc#' = t#Nc#)   & (alloc#Nc#' = compute_tn#Nc#);
[last_cam_sent] (cam#Nc# = cam#Nc#_fr_sent) -> 1 : (sent#Nc#'=sent#Nc#+1) & (cam#Nc#' = cam#Nc#_ready) & (q#Nc#' = q#Nc# + q#Nc#_inc)  & (old_q#Nc#' = q#Nc#); // increment the quality on succesful send and save the old quality ;
[last_cam_sent] (cam#Nc# = cam#Nc#_fr_drop) -> 1 : (drop#Nc#'=drop#Nc#+1) & (cam#Nc#' = cam#Nc#_ready) & (q#Nc#' = old_q#Nc#) & (q#Nc#_inc' = floor(q#Nc#_inc/2)); // On frame drop, reset quality to old successful one, and reduce the increment size by 2;
[bw_allocated] (cam#Nc# = cam#Nc#_ready) -> 1 : (cam#Nc#' = cam#Nc#_thr_check) & (s#Nc#'= framesize#Nc#);
[] (cam#Nc# = cam#Nc#_thr_check)  & (!end) -> 1 : (cam#Nc#' = cam#Nc#_calc_fr) & (want_rm' = (t#Nc# - ceil(s#Nc# / bytes_millis))/t#Nc# > threshold_event | (t#Nc# - ceil(s#Nc# /bytes_millis))/t#Nc# < -threshold_event ? true : want_rm = true);
endmodule


// ******************** CAMERA MODULES (END) ********************

rewards "rm_calls"
[man_inter] true : 1; // Rewards 1 whenever man_inter label is activated
endrewards

#for i=1:Nc#
rewards "frame_dropped#i#"
   [last_cam_sent] cam#i# = cam#i#_fr_drop : 1;// Rewards 1 whenever the frame is dropped
endrewards
#end#

#for i=1:Nc#
rewards "frame_sent#i#"
  [last_cam_sent] cam#i# = cam#i#_fr_sent : 1;// Rewards 1 whenever the frame is dropped
endrewards
#end#

rewards "cost"
  [man_inter] true : 1;
  #for i=1:Nc#
    [last_cam_sent] cam#i# = cam#i#_fr_drop : 10;// Rewards 1 whenever the frame is dropped
  #end#
endrewards
