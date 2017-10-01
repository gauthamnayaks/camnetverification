# PRISM model checking: model with two cameras

This folder contains the model used to verify the system with two
cameras. The file _2cam.prism_ contains the specification of the
model elements, while the file _2cam.props_ contains the properties
that are verified.

## run.sh

The run script is what should be executed to perform the model
checking. One line should be changed in the file, before being able
to execute it correctly. The script assumes that PRISM has been
installed in a specific location, which should be given in line 3
as `PRISM_LOCATION=/PATH_TO_PRISM_FOLDER/prism/bin/prism`.
A link to the binary file should be specified. Initially, the
variable is set to `SET_ME`, to make sure that the execution fails
and an informative message is printed at the command line.

The run script calls the visualize script which summarizes the data.
With the current set of parameters, the script should produce the
following results.

```
--------------------------------------------------------------
 Verification with 20 frames, NON satisfied
--------------------------------------------------------------
['threshold_event', 'lambda1', 'lambda2', 'Result']
['0.01', '0.8', '0.95', '0.0']
['0.02', '0.8', '0.95', '0.0']
['0.03', '0.8', '0.95', '0.0']
['0.04', '0.8', '0.95', '0.0']
['0.05', '0.8', '0.95', '0.0']
--------------------------------------------------------------
 Verification with 30 frames, NON satisfied
--------------------------------------------------------------
['threshold_event', 'lambda1', 'lambda2', 'Result']
```

These results mean that if the length of the trace is 20 frames,
there are some sets of parameters (lambdas and threshold) for which
the system has not settled. The sets are then reported. With a
30 frames traces, on the contrary, for all the traces the stability
property is verified.

The script creates two intermediate files (`r20f.csv` and `r30f.csv`)
where all the results are stored to be accessed in the future.

## 2cam.prism

The file contains (from top to bottom):

* constants that are specified for the overall simulation,
* constants that are specified for the model behavior,
* global variables,
* approximated formulas for the frame size computation,
* computation of time slots for camera transmission,
* formulas for control at the camera level for both cameras,
* formulas for control at the network manager level,
* the scheduler module (the logic behind when to execute the manager),
* the module for camera 1,
* the module for camera 2 (equal to the above one except for the
  management of turns),
* code related to the computation of properties.

The first three constants are used to configure the model:

* `const bool synth_schedule` determines if PRISM should synthesize
  the best strategy, or it should be determined by the threshold-based
  logic,
* `const bool event` determines if the control used is event-based
  or periodic (false implies periodic control),
* `const double threshold_event` specifies the threshold used for the
  event based invocation (should be in the open interval 0..1) -- an
  unspecified threshold value implies that PRISM will ask for the
  value specification when the model is checked.
  
In the current version of the model, the values of
`const double lambda1` and `const double lambda2` are also unspecified
because we want to check properties for a set of possible values for
these two. The value of `const int max_frames` is also set at the
command line when invoking the script.

## 2cam.props

The file contains four different properties that can be checked:

* number of network manager interventions (ideally minimized),
* number of dropped frames (frames those frame size was higher than
  the available bandwidth)
* total cost (ideally minimized, in the paper we define the total
  cost as a loss of 10 for each dropped frame and of 1 for each
  network manager intervention, to penalize the loss of frames more
  than network bandwidth adjustments)
* stability (we reach an equilibrium where no more actions are taken
  if there are no disturbances)
  
## visualize.py

The file just contains some glue code to visualize immediately when
executing the run script if there are parameter sets for which the
stability property is not verified.

