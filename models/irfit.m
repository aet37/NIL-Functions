function y=irfit(x,t,z,absflag)
% Usage ... y=irfit(x,t,z)

verboseflag=0;
if length(x)==2, x(3)=1; end;
if (nargin<4), absflag=0; end;

A=x(1);
T1=x(2);
alpha=x(3);

y=A*(1-2*alpha*exp(-t/T1));

if (absflag), y=abs(y); end;

if (nargin>2),
  y=(y-z);
  if (verboseflag),
    disp(sprintf(' err= %e  (A= %e  T1= %e  alpha= %f)',sum(y.*y),A,T1,alpha));
  end;
end;

