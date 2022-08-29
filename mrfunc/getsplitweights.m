function [w,df]=getsplitweights(nsplits,splitfreq)
% Usage ... [w,df]=getsplitweights(nsplits,splitfreq)

if nargin<2, splitfreq=0; end;

if nsplits==3,
  w=(1/6)*[1 2 2 1];
  df=[-2*splitfreq -splitfreq +splitfreq +2*splitfreq];
elseif nsplits==2,
  w=(1/4)*[1 2 1];
  df=[-splitfreq 0 splitfreq];
elseif nsplits==1,
  w=(1/2)*[1 1];
  df=[-splitfreq splitfreq];
else,
  w=1*[1];
  df=[0];
end;

