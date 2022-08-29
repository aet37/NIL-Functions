function [err,ys,cc]=disp1d(x,parms,parms2fit,data1,data2)
% Usage ... [e,y,c]=disp1d(x,parms,parms2fit,data1,data2)
%
% x = [x0 A excl]

data1=data1(:);
data2=data2(:);

if ~isempty(parms2fit),
  parms(parms2fit)=x;
end;

x0=parms(1);
amp=parms(2);
excl_flag=parms(3);

ylen=length(data1);
ys=amp*yshift(data1,x0);

cc=ones(size(ys));
if (excl_flag)&(abs(x0)>1),
  yi=floor(abs(x0));
  if (yi>0.5*ylen)
    yi=floor(0.5*ylen);
  end;
  ii=[1:yi];
  if x0<0,
    ii=length(ys)-ii+1;
  end;
  cc(ii)=0;
end;
ys=ys.*cc;

ee=data2-ys;
err=ee(find(cc));


