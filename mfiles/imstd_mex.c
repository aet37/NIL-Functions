

/*
   Function: stdim.c

   Usage in Matlab: [y,ya,yc]=imstd_mex(im,neigh,overlap_flag,contrast_flag)

*/


/* Standard include files */
#include "mex.h"
#include "math.h"
#include "string.h"

/* Definitions */
#define VERBOSE_FLAG 0

/* Function definitions */
void stdavgim(double* stdim, double* avgim, double* im, long* imdim, long neigh, long overlap_flag);

/* Usage and help functions */
void printUsage()
{
  mexPrintf("  Usage ... [ystd,yavg,ycon]=imstd_mex(im,neigh,overlap_flag,contast_flag);\n");
  mexPrintf("    overlay_flag and contrast_flag are necessary but no functionality yet.\n");
}


/* Matlab interface function */
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
  double 	*im, *neigh, *overlap_flag, *contrast_flag;
  double	*stdim, *avgim, *conim;
  double	avgdiv_thr=1.0;
  long		imdim[2];
  long      	imX,imY,mm,nn;
  short     	verbose_flag=VERBOSE_FLAG;


  /* get input arguments */
  if((nrhs==0) || (nlhs==0) || (nrhs!=4)) {
    printUsage();
    mexErrMsgTxt("\n  Invalid number of inputs or outputs");
  }
  im = mxGetPr(prhs[0]);
  neigh = mxGetPr(prhs[1]);
  overlap_flag = mxGetPr(prhs[2]);
  contrast_flag = mxGetPr(prhs[3]);

  /* get dimension information of input parameters */
  imX=mxGetM(prhs[0]);
  imY=mxGetN(prhs[0]);

  /* verify information */
  if (verbose_flag) {
    mexPrintf("  im_dim=[ %d %d ]\n",imX,imY);
    mexPrintf("  overlap= %d   contrast= %d\n",(long)(*overlap_flag),(long)(*contrast_flag));
  }
  
  /* create new variables to return */
  if(!(plhs[0] = mxCreateDoubleMatrix(imX,imY,mxREAL))){mexErrMsgTxt("\nfailed to create a matrix");}
  if(!(plhs[1] = mxCreateDoubleMatrix(imX,imY,mxREAL))){mexErrMsgTxt("\nfailed to create a matrix");}
  if(!(plhs[2] = mxCreateDoubleMatrix(imX,imY,mxREAL))){mexErrMsgTxt("\nfailed to create a matrix");}
  imdim[0]=imX; imdim[1]=imY;
  stdim=mxGetPr(plhs[0]);
  avgim=mxGetPr(plhs[1]);
  conim=mxGetPr(plhs[2]);


  /* finally, call main c-function */
  stdavgim(stdim,avgim,im,imdim,(long)(*neigh),(long)(*overlap_flag));

  /* additional processing here -- create contrast */
  for (nn=0;nn<imY;nn++) { for (mm=0;mm<imX;mm++) {
    if (avgim[mm+nn*imX]<avgdiv_thr) {
      conim[mm+nn*imX]=0.0;
    } else {
      conim[mm+nn*imX]=stdim[mm+nn*imX]/avgim[mm+nn*imX];
    }
  } }
  
  /* clean up unneccesary variables */
  /* mxFree(var_name);  -- no variables to clear */
}


void stdavgim(double* stdim, double* avgim, double* im, long* imdim, long neigh, long overlap_flag)
{ 
  long 		mm, nn, oo, pp, xdim, ydim;
  long		mcnt, ncnt, mstep, nstep;
  long		oostart,ooend,ppstart,ppend;
  short		nleft, nright, ntop, nbot;
  double	tmpsum,tmpstd,tmpcnt;
  short		verbose_flag=VERBOSE_FLAG;

  xdim=imdim[0];
  ydim=imdim[1];

  nleft=(short)(ceil(((double)(neigh))/2.0))-1;
  nright=(short)(floor(((double)(neigh))/2.0));
  ntop=nleft;
  nbot=nright;

  /* -- no overlay functionality for now --
  if (overlap_flag) {
    mstep=1;
    nstep=1;
  } else {
    mstep=neigh;
    nstep=neigh;
  }
  */
  mstep=1; nstep=1;

  ncnt=0;
  for (nn=0; nn<ydim; nn=nn+nstep ) {
    mcnt=0;
    ppstart=nn-ntop;
    ppend=nn+nbot;

    if (ppstart<0) ppstart=0;
    if (ppend>(ydim-1)) ppend=ydim-1;

    for (mm=0; mm<xdim; mm=mm+mstep ) {
      oostart=mm-nleft;
      ooend=mm+nright;
      
      if (oostart<0) oostart=0;
      if (ooend>(xdim-1)) ooend=xdim-1;
 
      tmpsum=0.0;
      tmpstd=0.0;
      tmpcnt=0;
      for (pp=ppstart; pp<=ppend; pp++) {
        for (oo=oostart; oo<=ooend; oo++) {
          tmpsum=tmpsum+im[oo+pp*xdim];
          tmpcnt=tmpcnt+1.0;
        }
      }

      tmpsum=tmpsum/tmpcnt;
      avgim[mcnt+ncnt*xdim]=tmpsum;

      for (pp=ppstart; pp<=ppend; pp++) {
        for (oo=oostart; oo<=ooend; oo++) {
          tmpstd=tmpstd+(tmpsum-im[oo+pp*xdim])*(tmpsum-im[oo+pp*xdim]);
        }
      }
      tmpstd=pow(tmpstd/(tmpcnt-1.0), 0.5);
      stdim[mcnt+ncnt*xdim]=tmpstd;
     
      /* test
      if ((mm>(xdim-8))&&(nn>(ydim-8))) {
        mexPrintf("  m,n=[%d,%d]  nn=[%d,%d,%d,%d]  nt=[%d]  cnts=[%d,%d]\n",mm,nn,oostart,ooend,ppstart,ppend,tmpcnt,mcnt,ncnt);
      }
      */

      mcnt=mcnt+1;
    }

    ncnt=ncnt+1;
  }

}

