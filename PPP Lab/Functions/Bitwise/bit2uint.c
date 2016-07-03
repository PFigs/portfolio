#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mex.h"
#include <tmwtypes.h>
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    int i;
    double *in;
    double *out;
    uint16_T u4;
    char vec[4];
    
    if (nrhs < 1 || nrhs > 2) 
        mexErrMsgTxt("bit2num: invalid arguments");

    /* Pointers para a entrada e a saida */
    plhs[0] = mxCreateDoubleMatrix(1, 1,mxREAL);
    in      = mxGetPr(prhs[0]);
    out     = mxGetPr(plhs[0]);

    if (nrhs == 2){
        for (i = 0; i < 4; ++i) vec[3-i] = (char)in[i];    
    }
    else{
        for (i = 0; i < 4; ++i) vec[i] = (char)in[i];
    }
    
    
    u4 = *(uint16_T*)vec;
    memcpy(out, &u4, sizeof(uint16_T));
    
}
