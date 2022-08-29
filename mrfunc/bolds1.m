function [s,E,A]=bolds1(f,y)
% Requires the use of bold1

%f=interp1(told,fold,tnew);
%f=mflowmod(tnew,f,[1],[1 2 4 1]);
%fout=mfvmatch(f);

k1=267.5;
k2=4.3;
k3=25;
Bo=4.0;
Vo=0.03;
Xo=1.8e-3;
TE=40e-3;
Eo=0.5;
fo=1;
X=Xo*(1-y(:,1));
vmax=k1.*Bo.*X;
A=k2.*vmax.*TE.*Vo;
E=1-((1-Eo).^(fo./f));
s=k3*A.*E.*y(:,2);

%z=(z-z(length(z)))/z(length(z));

if nargout==0,
  figure(1)
  plot(s)
  title('Signal')
  figure(2)
  plot(E)
  title('Extraction')
  figure(3)
  plot(A)
  title('A')
end;

