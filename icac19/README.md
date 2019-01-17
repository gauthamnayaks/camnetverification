# ICCPS 2019

The folder contains the [PRISM](http://www.prismmodelchecker.org/)
sources that we have used to verify model properties for the paper
_Model Checking a Self-Adaptive Camera Network with Physical Disturbances_,
by Gautham Nayak Seetanadi, Karl-Erik Årzén, and Martina Maggio, submitted to
[International Conference on Cyber-Physical Systems 2019]
(/http://iccps.acm.org/2019/?q=node/10).

## Experiment 1

The folder contains the PRISM code to verify the three different models. The
deterministic, probabilistic and non-deterministic model. Execute the script run.sh
to verify all the three models and generate figure 7. For a quicker verification
execute the script run2to5.sh. This will run a smaller number of cameras if a
large amount of memory is unavailable and verifies properties faster.

### Props

This folder contains the different property files depending on the number of
cameras being verified

## Experiment 2

The folder contains the PRISM code to verify the cooperative vs competitive
behavior of the camera system. Execute the script run.sh to verify the different
properties and generate figure 8.

### Props

This folder contains the different property files depending on the number of
cameras being verified
