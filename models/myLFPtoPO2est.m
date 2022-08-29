function [y,h]=myLFPtoPO2est(x,tparms,sparms,parms2fit,tdata,udata,ydata)
% Usage ... y=myLFPtoPO2est(x,tparms,sparms,parms2fit,tdata,udata,ydata)
%
%

if (~isempty(x)),
  sparms(parms2fit)=x;
end;

nup=tparms(1);
ndown=tparms(2);
nupdown=nup+ndown+1;

up=[1 sparms(1)];
down=[1 sparms(nup+1)];
amp=sparms(end);

if (nup>1),
  for mm=2:nup,
    up=conv(up,[1 sparms(mm)]);
  end;
end;
if (ndown>1),
  for mm=2:ndown,
    down=conv(down,[1 sparms(nup+mm)]);
  end;
end;
%up,
%down,
%amp,
 
y=amp*mysol(up,down,udata,tdata);

if (nargout>1),
  uh=zeros(size(tdata));
  uh(1)=1;
  h=mysol(up,down,uh,tdata);
  %size(tdata), size(h),
end;


y=y+1;
if (nargin>6),
  y=y-ydata;
end;

