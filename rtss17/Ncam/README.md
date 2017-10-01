# PRISM model checking: model with N cameras

This folder contains the model used to verify the system with N
cameras. The file _Ncam.pp_ contains the specification of the
model elements, while the file _Ncam.props_ contains the properties
that are verified.

## run.sh

The run script is what should be executed to perform the model
checking. One line should be changed in the file, before being able
to execute it correctly. The script assumes that PRISM has been
installed in a specific location, which should be given in line 4
as `PRISM_LOCATION=/PATH_TO_PRISM_FOLDER/prism/bin/`. The linked
folder should contain the prism binary and the prism preprocessor
script for the model generation. The preprocessor can be downloaded
from the [PRISM website](http://www.prismmodelchecker.org/prismpp/).

Initially, the variable is set to `SET_ME`, to make sure that the
execution fails and an informative message is printed at the command
line.

The run script calls the visualize script which summarizes the data.
With the current set of parameters, the script should produce the
following results.

```
--------------------------------------------------------------
 Verification with 10 frames, NON satisfied
--------------------------------------------------------------
['threshold_event', 'Result']
['0.01', '0.0']
['0.02', '0.0']
['0.03', '0.0']
['0.04', '0.0']
['0.05', '0.0']
--------------------------------------------------------------
 Verification with 30 frames, NON satisfied
--------------------------------------------------------------
['threshold_event', 'Result']
```

These results mean that if the length of the trace is 10 frames,
there are some sets of parameters (some values of the threshold) for
which the system has not settled. The sets are then reported. With a
30 frames traces, on the contrary, for all the traces the stability
property is verified.

The script creates two intermediate files (`r10f.csv` and `r30f.csv`)
where all the results are stored to be accessed in the future.

## Ncam.pp

The file contains a generalization of the 2cam.prism file, and uses
the initial constant Nc to determine the number of cameras. Nc is set
in the run script in line 5 and currently set to 3.

## Ncam.props

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

