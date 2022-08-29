function xdot=mymodel(t,x)

u=0;
u=myconv(mypulse(t,1,1,1),mypulse(t,5,1,5));

xdot(1)= -.5*x(1) -.125*x(2) + u;
xdot(2)= x(1);
