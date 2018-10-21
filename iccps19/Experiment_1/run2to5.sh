#!/bin/bash

cd deterministic
./run2to5.sh
mv results_deterministic.csv ../.
cd ..

cd nondeterministic
./run2to5.sh
mv results_nondeterministic.csv ../.
cd ..

cd probabilistic
./run2to5.sh
mv results_probabilistic.csv ../.
cd ..

mv results_deterministic.csv results/
mv results_probabilistic.csv results/
mv results_nondeterministic.csv results/

cd results/
pdflatex Figure7.tex &>/dev/null
rm -rf Figure7.aux Figure7.log
