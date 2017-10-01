# Network Manager Overhead Computation

This folder contains the sources used to generate the overhead plot in the paper (Figure 6). The process requires: gcc, a version of latex that includes tikz and pgfplots.

## run.sh

The run script compiles the program `overhead.c` and runs it. The program produces the file `overhead.csv`, containing the results of the overhead computation. The latex (tikz, pgfplots) file `graph.tex` is finally compiled, producing the resulting figure `graph.pdf`.

## overhead.c

The C program replicates the computation of bandwidth allocation with a vector of cameras of size from 1 to 100. The program demonstrates that the complexity of the network manager computation scales linearly with the number of cameras.

## graph.tex

This file contains the latex sources for the generation of the tikz figure.
