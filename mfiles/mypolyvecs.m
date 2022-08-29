function y=mypolyvecs(pp,x0)
% Usage ... y=mypolyvecs(pp,x0)
%

np=length(pp);
rotm=[cos(pi/2) -sin(pi/2);sin(pi/2) cos(pi/2)];

slope=0;
for mm=1:np-1,
  slope=slope+(np-mm)*pp(mm)*(x0(1)^(np-mm-1));
end;

dx=1;
y0=polyval(pp,x0);
dy=slope*dx;
pslope=-1/slope;

tv=[dx dy];
tv=tv/sqrt(tv(1)^2+tv(2)^2);
pv=tv*rotm;
pv2=[dx pslope*dx];
pv2=pv2/sqrt(pv2(1)^2+pv2(2)^2);

y.slope=slope;
y.pslope=pslope;
y.tv=tv;
y.pv=pv;

if nargout==0,
  x1=[-500:500]/500;
  x1=5*x1*round(log10(x0));
  x1=x1+x0;
  y1=polyval(pp,x1);
  x2=[-dx:0.1:dx]+x0;
  y2=slope*x2+(y0-slope*x0);
  y3=pslope*x2+(y0-pslope*x0);
  plot(x1,y1,x2,y2,x2,y3)
end;

