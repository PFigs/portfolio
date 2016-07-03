#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    short int i;
    double *in;
    double *out;
    double r8;
    char vec[8];
    
    if (nrhs < 1 || nrhs > 2) 
        mexErrMsgTxt("bit2num: invalid arguments");
        
    /* Pointers para a entrada e a saida */
    plhs[0] = mxCreateDoubleMatrix(1, 1,mxREAL);
    
    in  = mxGetPr(prhs[0]);
    out = mxGetPr(plhs[0]);

    if (nrhs == 2){
        for (i = 0; i < 8; ++i) vec[7-i] = (char)in[i];    
    }
    else{
        for (i = 0; i < 8; ++i) vec[i] = (char)in[i];
    }
    
    r8 = *(double*)vec;
    memcpy(out, &r8, sizeof(double));
}
