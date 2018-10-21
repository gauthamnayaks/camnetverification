#!/bin/bash

rm -f *.csv

cd deterministic
rm -f *.prism *.sta *.flip *.all *.csv
cd ..

cd nondeterministic
rm -f *.prism *.sta *.flip *.all *.csv
cd ..

cd probabilistic
rm -f *.prism *.sta *.flip *.all *.csv
cd ..

cd results/
rm -rf Figure7.aux Figure7.log
rm -f *.csv
