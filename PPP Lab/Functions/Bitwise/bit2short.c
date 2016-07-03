#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int i;
    double *in;
    double *out;
    short i2;
    char vec[2];
    
    if (nlhs != 1 || nrhs != 1) mexErrMsgTxt("bit2num: invalid arguments");
    
    /* Pointers para a entrada e a saida */
    plhs[0] = mxCreateDoubleMatrix(1, 1,mxREAL);
    
    in = mxGetPr(prhs[0]);
    out = mxGetPr(plhs[0]);

    for (i = 0; i < 2; ++i) vec[i] = (char)in[i];
    
    i2 = *(short*)vec;
    memcpy(out, &i2, sizeof(short));
}
