function [hx,ym,xm,ys]=myhist(x,y,nbins)
% Usage ... [hx,ym,xm]=myhist(x,y,nbins)

xmin=min(x);
xmax=max(x);

if length(nbins)>1,
  bb=nbins;
else,
  bb=([1:nbins]/nbins)*(xmax-xmin)+xmin;
end;
bd=bb(2)-bb(1);
for mm=1:length(bb),
  if mm==1,
    tmpi=find((x<=bb(mm))&(x>=0));
  else,
    tmpi=find((x<=bb(mm))&(x>bb(mm-1)));
  end;
  hx(mm)=length(tmpi); 
  if ~isempty(tmpi),
    ym(mm)=mean(y(tmpi));
    xm(mm)=mean(x(tmpi));
    ys(mm)=std(y(tmpi));
  else,
    ym(mm)=0;
    xm(mm)=bb(mm)-bd;
    ys(mm)=0;
  end;
end;

if nargout==0,
  subplot(211)
  plot(bb,hx,'-x')
  subplot(212)
  plot(xm,ym,'-xr')
  clear hx ym xm
end;

