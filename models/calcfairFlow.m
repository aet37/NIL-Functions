function [F,dMout]=calcfairFlow(TIs,dMs,parms,optvar)
% Usage ... F=calcfairFlow(TIs,dMs,[T1 alpha M0 lambda],optvar)

if nargin<4,
  optvar=optimset('lsqnonlin');
  optvar.TolFun=1e-10;
  optvar.TolX=1e-10;
  optvar.MaxIter=300;
  %optvar.Display='iter';
end;

if length(parms)==3,
  Fmax=[1000 100];
  Fmin=[0 1e-6];
  Fguess=[1 1];
else,
  Fmax=1000; Fmin=0;
  Fguess=1;
end;

x1=lsqnonlin('fairfit',Fguess,Fmin,Fmax,optvar,TIs,parms,dMs);
dMout=fairfit(x1,TIs,parms);
F=x1;

if nargout==0,
  plot(TIs,dMs,TIs,dMout)
  if length(parms)==3,
    title(sprintf('Flow= %f 1/s, T1= %f ms',F(1),1000*F(2)))
  else,
    title(sprintf('Flow= %f 1/s, T1= %f ms',F(1),1000*parms(1)))
  end;
  xlabel('Time')
  ylabel('dM')
end;

