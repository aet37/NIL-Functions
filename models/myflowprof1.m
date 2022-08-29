function y=myflowprof1(x,parms,parms2fit,ri,data)
% Usage ... y=myflowprof1(x,parms,parms2fit,rr,data)
%
% x=[r0pos, diam, pow, vmax]

if ~isempty(parms2fit),
  parms(parms2fit)=x;
end;

rcenter=parms(1);
r0=parms(2)/2;
pow=parms(3);
vmax=parms(4);

rr=ri-rcenter;
velp=vmax*(1-(rr/r0).^pow);

if nargin==5,
  y=data-velp;
else,
  y=velp;
end;

if nargout==0,
  rri=[rr(1):(rr(end)-rr(1))/100:rr(end)];
  velpi=vmax*(1-(rri/r0).^pow);
  if nargin==5,
    plot(rr,data,'x',rri,velpi)
  else,
    plot(rri,velpi)
  end;
end;

