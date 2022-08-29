function f=tc_stats(x,t,t_act,options)
% Usage ... f=tc_stats(x,t,t_act,options)
%
% This function calculates some of statistic
% relevant to fMRI. The order of the
% statistics are:
%  1- mean of the baseline [t(1):t_act]
%  2- std  of the baseline [t(1):t_act]
%  3- min of the initial phase of activation
%  4- index of the min of the initial phase of activation
%  5- max of the time series
%  6- index of the max of the time series
%  7- lin interpolated fwhm of the positive phase
%  8- min of the time series
%  9- index of the min of the time series
% Options: 
%  1- return equivalent time not index

ACTIVITY_THR=0.1;

if nargin<4, options(1)=0; end;

n_act=find(t==t_act);
if isempty(n_act),
  tmp=find(t>t_act);
  n_act=tmp(1)-1;
end;

baseline=x(1:n_act);
f(1)=mean(x(1:n_act));
f(2)=std(x(1:n_act));

response=x(n_act:length(x));
[f(5),f(6)]=max(x(n_act:length(x)));
f(6)=f(6)+n_act-1;

n_ph1=find(x(n_act:length(x))>(ACTIVITY_THR*f(5)))+n_act-1;
phase1=x(n_act:n_ph1(1));
[f(3),f(4)]=min(x(n_act:n_ph1(1)));
f(4)=f(4)+n_act-1;

% n_pt1 is the near onset time and n_pt2 is the far onset index
% n_pt1 needs to be compared with against n-1 while n_pt2 needs
% to be compared against n+1
% Note: equal spacing is assumed at least in the vicinity of points
% n_pt1 and n_pt2

n_ph2=find(x(n_ph1:length(x))<0)+n_ph1(1)-1;
if isempty(n_ph2),
  n_ph2(1)=length(x);
end;
if n_ph2(1)<=f(6),
  for m=2:length(n_ph2),
    if n_ph2(m)>f(6),
      n_ph2(1)=n_ph2(m);
      break;
    end;
  end;
end;

[f(8),f(9)]=min(x(n_ph2(1)-1:length(x)));
f(9)=f(9)+n_ph2(1)-1-1;

for m=n_ph2(1):-1:f(6),
  if x(m)>=0.5*f(5),
    n_pt2=m;
    break;
  else,
    n_pt2=m;
  end;
end;
for m=n_ph1(1)-1:f(6),
  if x(m)>=0.5*f(5),
   n_pt1=m;
   break;
  else,
   n_pt1=1;
  end;
end;

if (n_pt1(1)<=1),
  disp('Warning: Changing nearside index');
  n_pt1=n_pt1+1;
end;
if (n_pt2(1)>=length(x)),
  disp('Warning: Changing farside index');
  n_pt2=n_pt2-1;
end;

slope=(x(n_pt1)-x(n_pt1-1))/1.0;
dx=(x(n_pt1)-0.5*f(5))/slope;
pt1=n_pt1-dx;
t_pt1=t(n_pt1)-(t(n_pt1)-t(n_pt1-1))*dx;

slope=(x(n_pt2)-x(n_pt2+1))/1.0;
dx=(x(n_pt2)-0.5*f(5))/slope;
pt2=n_pt2+dx;
t_pt2=t(n_pt2)-(t(n_pt2)-t(n_pt2+1))*dx;

f(7)=pt2-pt1;

if options(1)==1;
  f(4)=t(f(4));
  f(6)=t(f(6));
  f(9)=t(f(9));
  f(7)=t_pt2-t_pt1;
end;

f=f(:);

if nargout==0,
  plot(t,x,'-',[t_act t_act],0.1*f(5)*[0 1],'-',[t_pt1 t_pt2],0.5*f(5)*[1 1],'--',[t_act t_pt1 t_pt2 t(f(4)) t(f(6)) t(f(9))],[0 0.5*f(5)*[1 1] f(3) f(5) f(8)],'x')
 axis([t(1) t(length(t)) 1.1*f(8) 1.1*f(5)])
 grid
end;

