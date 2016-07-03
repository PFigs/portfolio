#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int i;
    double *in;
    double *out;
    float r4;
    char vec[4];
    
    if (nlhs != 1 || nrhs != 1) mexErrMsgTxt("bit2num: invalid arguments");
    
    /* Pointers para a entrada e a saida */
    plhs[0] = mxCreateDoubleMatrix(1, 1,mxREAL);
    
    in = mxGetPr(prhs[0]);
    out = mxGetPr(plhs[0]);

    for (i = 0; i < 4; ++i) vec[i] = (char)in[i];
    
    r4 = *(float*)vec;
    memcpy(out, &r4, sizeof(float));
}
