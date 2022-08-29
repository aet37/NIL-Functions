function f=exp1decayfit(x,y)
% Usage ... f=exp1decayfit(x,y)

if nargin==1, y=x; x=zeros(size(y)); x(1:end)=[1:length(y)]; end;

yb=mean(y(end-5:end));
y=y-yb;

xx=polyfit(x,log(y),1);

I0=exp(xx(2));
TT=-1/xx(1);

f=real(I0*exp(-x/TT))+yb;

%f.fit=I0*exp(-x/TT)+yb;
%f.xx=xx;
%f.I0=I0;
%f.tau=TT;
%f.ybase=yb;

