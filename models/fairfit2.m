function z=fairfit(x,TIs,parms,y)
% Usage ... z=fairfit(x,TIs,[MTT T1 T1a alpha M0 lambda],dMs)

if length(parms)==3,
  flow=x(1);
  MTT=x(2);
  T1=x(3);
  T1a=x(4);
  alpha=parms(1);
  M0=parms(2);
  lambda=parms(3);
else,
  flow=x(1);
  MTT=x(2);
  T1=x(3);
  T1a=parms(1);
  alpha=parms(2);
  M0=parms(3);
  lambda=parms(4);
end;

dR = (1/T1 - 1/T1a);
dM =-2*M0*alpha*(flow/lambda)*(1/dR)*exp(-TIs/T1a)*(1-exp(-dR*(TIs-MTT)));
dM(find(TIs<MTT))=0;

cond=flow*TIs/lambda;

if (nargin>3),
  z=(y-dM);
else,
  z=dM;
end;

if (nargout==0),
  plot(TIs,dM)
  title(sprintf('Flow= %f 1/s, T1= %f ms',flow,1000*T1))
  xlabel('Time')
  ylabel('dM')
end;

