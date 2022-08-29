function z=fairfit(x,TIs,parms,y)
% Usage ... z=fairfit(x,TIs,[T1 alpha M0 lambda],dMs)

if length(parms)==3,
  flow=x(1);
  T1=x(2);
  alpha=parms(1);
  M0=parms(2);
  lambda=parms(3);
else,
  flow=x(1);
  T1=parms(1);
  alpha=parms(2);
  M0=parms(3);
  lambda=parms(4);
end;

dM=2*M0*alpha*exp(-TIs/T1)*flow.*TIs/lambda;

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

