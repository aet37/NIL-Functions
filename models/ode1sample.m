
clear all

t=[0:100];
t=t(:);

u=zeros(size(t));
u(11:20)=ones([10 1]);

h=t(2)-t(1);
tau=2;

y(1)=0;
for m=1:length(t)-1,
  y(m+1) = y(m) + h*( (1/tau)*u(m) - (1/tau)*y(m)  );
end;

plot(t,u,t,y)

