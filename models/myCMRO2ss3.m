function y=myCMRO2ss(x,parms,data,mintype)
% Usage ... y=myCMRO2ss(x,parms,data)
%
% x = [F0 PS Pt]
% parms = [dF Pa]
% data = [dCMRO2]

if (nargin<4), mintype=1; end;

F0=parms(3);
PS=parms(4);
Pt=x(1);

F1=parms(1)+1;
Pa=parms(2);

FF=F0*[1 F1];
[CMR,EE]=valabregue3fff(FF,PS,Pt,Pa);
yy=(CMR(2)-CMR(1))/CMR(1);

if (nargin>2),
  dCMR=data;
  y=dCMR-yy;
  if (mintype==2),
    y=abs(y);
  else,
    y=y*ones([1 10]);
  end;
else,
  y=yy;
end;

