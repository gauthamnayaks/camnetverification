#!/bin/bash

gcc overhead.c -w -o overhead -lm
./overhead > overhead.csv
pdflatex graph.tex &>/dev/null
rm -rf graph.aux graph.log
echo "[Overhead computation completed] results saved in graph.pdf"
