
clear all

t=[0:1e-4:1e-2]';
v=zeros([length(t) 3]);
v(:,3)=0.01*ones([length(t) 1]);	% m/s

G=zeros([length(t) 3]);
G(:,3)=2*rect(t,4e-3,3e-3)-2*rect(t,4e-3,6e-3);		% G/cm

x=movspin(t,100*v);		% for cm/s
phs=movspinphs(G,x,t);

movspinphs(G,x,t);

