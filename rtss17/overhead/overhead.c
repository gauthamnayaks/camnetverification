#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#define MAX_BW 1
#define MIN_BW 0.01
#define EPS 0.4
#define MAX_ITERATIONS 100000
#define MAX_CAMERAS 100

double err[]; // matching function
double lambda[]; // lambdas
double bw_old[]; // old bandwidth
double bw[]; // new computed bandwidth

double rand_double() {
    double r = (double)rand();
    return r / (double)RAND_MAX ;
}

void compute_bw(int N) {
  int c = 0; // loop over cameras

  int sumlambdaerr = 0.0;
  for (c=0; c<N; c++) {
    err[c] = rand_double(); // additional overhead
    sumlambdaerr += lambda[c] * err[c];
  }
  
  for (c=0; c<N; c++) {
    bw[c] = bw_old[c] + EPS * (-lambda[c] * err[c] + sumlambdaerr * bw_old[c]);
    bw_old[c] = bw[c];
    bw[c] = fmin(MAX_BW, bw_old[c]);
    bw[c] = fmax(MIN_BW, bw_old[c]);
  }
}

int main(int argc, char** argv) {
  
  int N;
  long timing = -1;
  srand(time(NULL));
  
  for (N=1; N<=MAX_CAMERAS; N++) {
    while(timing<0) {
      // initialization
      int c = 0;
      for (c=0; c<N; c++) {
        lambda[c] = rand_double();
        bw_old[c] = 1.0 / N;
        bw[c] = 1.0 / N;
      }
      struct timespec tstart = {0,0}, tend = {0,0};
      int i = 0;
  
      // for each iteration    
      clock_gettime(CLOCK_REALTIME, &tstart);
      for (i=0; i<MAX_ITERATIONS;i++) {
        compute_bw(N);
      }
      clock_gettime(CLOCK_REALTIME, &tend);
      timing = tend.tv_nsec - tstart.tv_nsec;
    }
    double iteration_overhead = (double) timing / (double) MAX_ITERATIONS;
    printf("%d, %f, %d, %ld\n", N, iteration_overhead, MAX_ITERATIONS, timing);
    timing = -1;
  }
  
}


