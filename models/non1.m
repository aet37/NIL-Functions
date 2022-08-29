function ydot=fom1(t,y)
% First order model #1

% Input
uwidth=5;
ustart=10.1;
uamp=1;
u=mypulse(t,uwidth,uamp,ustart)+mypulse(t,uwidth,uamp,ustart+10);

% Parameters
tau=15;
shp=25;
theta=.5;
a=1;
b=2;	% undershoot depth
c=3;	% undershoot length
nonamp=0;
amp1=1;
tau1=15;

fun1= ones(size(t));
if (nonamp),
  for m=1:length(t), if (t(m)>=ustart), fun1(m)=exp(-(t(m)-ustart)/tau1);end;end;
end;
fun2= 1./( 1 +exp( -shp*( y(1) -theta ) ));

ydot(1)= amp1.*fun1.*( u - a*y(1) - b*y(2) );
ydot(2)= ( fun2 - c*y(2) )/tau;
