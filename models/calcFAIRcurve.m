function x1=calcFAIRcurve(t,alpha,Mob,T1b,fairvals,optvar)
% Usage ... [tau f dt]=calcFAIRcurve(t,alpha,Mob,T1b,fairvals,optvar)

if nargin<6,
  optvar=optimset('lsqnonlin');
  optvar.TolFun=1e-10;
  optvar.TolX=1e-10;
  optvar.MaxIter=600;
end;

taumax=100; 	taumin=0;
fmax=100;	fmin=0;
dtmax=10;     	dtmin=0;
mymax=[taumax fmax dtmax];
mymin=[taumin fmin dtmin];

tauguess=1;
fguess=1;
dtguess=1;
myguess=[tauguess fguess dtguess];
fairguess=FAIR_curve(myguess,t,alpha,Mob,T1b);

x1=lsqnonlin('FAIR_curve',myguess,mymin,mymax,optvar,t,alpha,Mob,T1b,fairvals);
fairout=FAIR_curve(x1,t,alpha,Mob,T1b);

if nargout==0,
  plot(t,fairvals,'x',t,fairout,'-',t,fairguess,'-')
end

