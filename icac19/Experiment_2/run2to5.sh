#!/bin/bash

# ----------------------------------- variables to set
MIN_CAM=2
MAX_CAM=5
# ----------------------------------- variables to set end

PRISM_JAVAMAXMEM=100g
export PRISM_JAVAMAXMEM

PRISM_FOLDER=/work/gautham/Software/prism-games-2.0.beta3-linux64/bin/
PRISM_LOCATION=${PRISM_FOLDER}prism
PRISMPP_LOCATION=${PRISM_FOLDER}prismpp
MODEL_PP=Ncam.pp
MODEL_FILE=Ncam.prism

rm -f results.csv

for NUM_CAMERAS in `seq $MIN_CAM $MAX_CAM`
do

PROPERTY_FILE=props/$NUM_CAMERAS.props

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

sed -i 's/ /,/g' ./results.csv
sed -i 's/ //g' ./results.csv
done

rm -f ./results_collab.csv
echo 'n,mi+,mi-,ci+,ci-,coi+,coi-,md+,md-,cd+,cd-,cod+,cod-,ms+,ms-,cs+,cs-,cos+,cos-,mc,cc,coc,states' >> ./results_collab.csv
python process_results.py >> ./results_collab.csv
sed -i 's/,/,\t/g' ./results_collab.csv
#rm -f results.csv
rm -f *.flip
rm *.all *.sta

mv results_collab.csv results/

cd results/
pdflatex Figure8.tex
rm -rf Figure8.aux Figure8.log
