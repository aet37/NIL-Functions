function [e,y_predi]=phys_model1(x,t,y,model,ic,num,den,uparms)
% Usage ... [e,y_predi]=phys_model1(x,t,y,model,ic,num,den,uparms)
%
% t,u - time vector and input waveform
% model - function name for model to be used
% ic - initial conditions for model
% num,den - system to describe flow behavior from input
% uparms - are the parameters of the input function except lag

% Typical parameters: x [2 0 0 1 .08 1] ic [1 1] num [1] den [1 1/9] u [2 20 .25 1]

TOL=1e-3;

for m=1:length(t),
  u(m)=mtrap1(t(m),uparms(1),uparms(2),uparms(3),uparms(4),x(1));
end;

basal_flow=u(length(u));
if (basal_flow~=0),
  u=u-basal_flow;
else,
  basal_flow=1;
end;

[t_model,y_model]=ode23ap8(model,t(1),t(length(t)),ic,TOL,0,t,u,num,den,x(2),x(3),x(4),x(5));
Finc=interp1(t,u,t_model);
Finc=basal_flow+0.5*mflowmod(t_model,Finc,num,den);

y_pred=x(6)*bolds1(Finc,y_model);
y_predi=interp1(t_model,y_pred,t);
plot(t,y_predi,t,y)
disp(x);

e=y_predi-y;
