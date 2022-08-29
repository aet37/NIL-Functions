function z=mflowmod(t,w,num,den,width_mod)
% Usage ... y=mflowmod(t,x,num,den,width_mod)
%
% Models the flow pattern given the input waveform.

if nargin<5,
  width_mod=0;
end;

if nargin<3,
  tau=9;
  num=[1];
  den=[1 1/tau];
end;

if width_mod,
  broad=rect(t,width_mod,0);
  b_area=trapz(t,broad);
  %width_mod,
  broad=(1/b_area)*broad;
  w=myconv(w,broad);
end;

z=mysol(num,den,w,t);
