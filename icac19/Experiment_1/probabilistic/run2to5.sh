#!/bin/bash

# ----------------------------------- variables to set
MIN_CAM=2
MAX_CAM=5
# ----------------------------------- variables to set end

PRISM_JAVAMAXMEM=100g
export PRISM_JAVAMAXMEM

PRISM=$(command -v prism)
PRISM_FOLDER=${PRISM:0:-5}
PRISM_LOCATION=${PRISM_FOLDER}prism
PRISMPP_LOCATION=${PRISM_FOLDER}prismpp
MODEL_PP=Ncam.pp
MODEL_FILE=Ncam.prism

rm -f results.csv

for NUM_CAMERAS in `seq $MIN_CAM $MAX_CAM`
do

PROPERTY_FILE=../props/$NUM_CAMERAS.props

$PRISMPP_LOCATION $MODEL_PP $NUM_CAMERAS > $MODEL_FILE

$PRISM_LOCATION $MODEL_FILE $PROPERTY_FILE -exportresults $NUM_CAMERAS.all -exportstates $NUM_CAMERAS.sta

STATES=`wc -l $NUM_CAMERAS.sta | awk '{print $1}'`

sed -i '/Result/d' ./$NUM_CAMERAS.all #Delete unnecessary lines
sed -i '/<</d' ./$NUM_CAMERAS.all
sed -i '/^\s*$/d' ./$NUM_CAMERAS.all #delete empty files

sed -i '1i'$NUM_CAMERAS  $NUM_CAMERAS.all #add number of cameras
echo ",$STATES" >> $NUM_CAMERAS.all
python -c "import sys; print('\n'.join(' '.join(c) for c in zip(*(l.split() for l in sys.stdin.readlines() if l.strip()))))" < $NUM_CAMERAS.all > $NUM_CAMERAS.flip

cat $NUM_CAMERAS.flip >> results.csv
sed -i 's/R{"rm_calls"}max=?/,/g' ./results.csv
sed -i 's/R{"rm_calls"}min=?/,/g' ./results.csv
sed -i 's/R{"frame_dropped1"}max=?/,/g' ./results.csv
sed -i 's/R{"frame_dropped1"}min=?/,/g' ./results.csv
sed -i 's/R{"frame_dropped2"}max=?/,/g' ./results.csv
sed -i 's/R{"frame_dropped2"}min=?/,/g' ./results.csv
sed -i 's/R{"frame_dropped3"}max=?/,/g' ./results.csv
sed -i 's/R{"frame_dropped3"}min=?/,/g' ./results.csv
sed -i 's/R{"frame_dropped4"}max=?/,/g' ./results.csv
sed -i 's/R{"frame_dropped4"}min=?/,/g' ./results.csv
sed -i 's/R{"frame_dropped5"}max=?/,/g' ./results.csv
sed -i 's/R{"frame_dropped5"}min=?/,/g' ./results.csv
sed -i 's/R{"frame_dropped6"}max=?/,/g' ./results.csv
sed -i 's/R{"frame_dropped6"}min=?/,/g' ./results.csv
sed -i 's/R{"frame_dropped7"}max=?/,/g' ./results.csv
sed -i 's/R{"frame_dropped7"}min=?/,/g' ./results.csv
sed -i 's/R{"frame_dropped8"}max=?/,/g' ./results.csv
sed -i 's/R{"frame_dropped8"}min=?/,/g' ./results.csv
sed -i 's/R{"frame_dropped9"}max=?/,/g' ./results.csv
sed -i 's/R{"frame_dropped9"}min=?/,/g' ./results.csv
sed -i 's/R{"frame_sent1"}max=?/,/g' ./results.csv
sed -i 's/R{"frame_sent1"}min=?/,/g' ./results.csv
sed -i 's/R{"frame_sent2"}max=?/,/g' ./results.csv
sed -i 's/R{"frame_sent2"}min=?/,/g' ./results.csv
sed -i 's/R{"frame_sent3"}max=?/,/g' ./results.csv
sed -i 's/R{"frame_sent3"}min=?/,/g' ./results.csv
sed -i 's/R{"frame_sent4"}max=?/,/g' ./results.csv
sed -i 's/R{"frame_sent4"}min=?/,/g' ./results.csv
sed -i 's/R{"frame_sent5"}max=?/,/g' ./results.csv
sed -i 's/R{"frame_sent5"}min=?/,/g' ./results.csv
sed -i 's/R{"frame_sent6"}max=?/,/g' ./results.csv
sed -i 's/R{"frame_sent6"}min=?/,/g' ./results.csv
sed -i 's/R{"frame_sent7"}max=?/,/g' ./results.csv
sed -i 's/R{"frame_sent7"}min=?/,/g' ./results.csv
sed -i 's/R{"frame_sent8"}max=?/,/g' ./results.csv
sed -i 's/R{"frame_sent8"}min=?/,/g' ./results.csv
sed -i 's/R{"frame_sent9"}max=?/,/g' ./results.csv
sed -i 's/R{"frame_sent9"}min=?/,/g' ./results.csv
sed -i 's/ //g' ./results.csv

done

rm -f ./results_probabilistic.csv
echo 'n,i+,i-,d+,d-,s+,s-,c,states' >> ./results_probabilistic.csv
python process_results.py >> ./results_probabilistic.csv
sed -i 's/,/,\t/g' ./results_probabilistic.csv
#rm -f results.csv
rm -f *.flip
rm *.all *.sta
