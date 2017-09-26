#!/bin/bash

PRISM_LOCATION=SET_ME
MODEL_FILE=2cam.prism
PROPERTY_FILE=2cam.props
PROPERTY_NUMBER=4

MIN_THRESHOLD=0.01
MAX_THRESHOLD=0.05
STEP_THRESHOLD=0.01

MIN_LAMBDA=0.8
MAX_LAMBDA=0.99
STEP_LAMBDA=0.05

RESULT_FILE20=r20f.csv
RESULT_FILE30=r30f.csv

if [ $PRISM_LOCATION = "SET_ME" ]
then
  echo "EXECUTION FAILED: set the prism location correctly"
  exit -1
fi

# ----------------------------------- command
$PRISM_LOCATION -explicit \
$MODEL_FILE $PROPERTY_FILE -prop $PROPERTY_NUMBER \
-const threshold_event=$MIN_THRESHOLD:$STEP_THRESHOLD:$MAX_THRESHOLD,\
lambda1=$MIN_LAMBDA:$STEP_LAMBDA:$MAX_LAMBDA,\
lambda2=$MIN_LAMBDA:$STEP_LAMBDA:$MAX_LAMBDA,\
max_frames=20 \
-exportresults $RESULT_FILE20
# ----------------------------------- command end

# ----------------------------------- command
$PRISM_LOCATION -explicit \
$MODEL_FILE $PROPERTY_FILE -prop $PROPERTY_NUMBER \
-const threshold_event=$MIN_THRESHOLD:$STEP_THRESHOLD:$MAX_THRESHOLD,\
lambda1=$MIN_LAMBDA:$STEP_LAMBDA:$MAX_LAMBDA,\
lambda2=$MIN_LAMBDA:$STEP_LAMBDA:$MAX_LAMBDA,\
max_frames=30 \
-exportresults $RESULT_FILE30
# ----------------------------------- command end

python visualize.py
