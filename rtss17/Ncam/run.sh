#!/bin/bash

# ----------------------------------- variables to set
PRISM_FOLDER=SET_ME # example /home/user/prism/bin/
NUM_CAMERAS=3
# ----------------------------------- variables to set end

PRISM_LOCATION=${PRISM_FOLDER}prism
PRISMPP_LOCATION=${PRISM_FOLDER}prismpp
MODEL_PP=Ncam.pp
MODEL_FILE=Ncam.prism
PROPERTY_FILE=Ncam.props
PROPERTY_NUMBER=4

MIN_THRESHOLD=0.01
MAX_THRESHOLD=0.05
STEP_THRESHOLD=0.01

RESULT_FILE10=r10f.csv
RESULT_FILE30=r30f.csv

if [ $PRISM_FOLDER = "SET_ME" ]
then
  echo "EXECUTION FAILED: set the prism location correctly"
  exit -1
fi

export PATH=${PRISM_FOLDER}:${PATH}
$PRISMPP_LOCATION $MODEL_PP $NUM_CAMERAS > $MODEL_FILE

# ----------------------------------- command
$PRISM_LOCATION -explicit \
$MODEL_FILE $PROPERTY_FILE -prop $PROPERTY_NUMBER \
-const threshold_event=$MIN_THRESHOLD:$STEP_THRESHOLD:$MAX_THRESHOLD,\
max_frames=10 \
-exportresults $RESULT_FILE10
# ----------------------------------- command end

# ----------------------------------- command
$PRISM_LOCATION -explicit \
$MODEL_FILE $PROPERTY_FILE -prop $PROPERTY_NUMBER \
-const threshold_event=$MIN_THRESHOLD:$STEP_THRESHOLD:$MAX_THRESHOLD,\
max_frames=30 \
-exportresults $RESULT_FILE30
# ----------------------------------- command end

python visualize.py
