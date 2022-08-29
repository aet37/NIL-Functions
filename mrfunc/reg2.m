function [c,r,SSE]=reg2(x,y,options,order)
% Usage ... [c,r,SSE]=reg2(x,y,options,order)
%
% x and y must be in coolumns

if nargin<4,
  order=1;
end;
if nargin<3,
  options=[0];
end;

unity_line=find(options==3);
if isempty(unity_line),
  ul_opt=0;
else,
  ul_opt=1;
end;

revert_axis=find(options==2);
if isempty(revert_axis),
  ra_opt=0;
else,
  ra_opt=1;
end;

% entry of '1' in the options vector activates disregard zeros
disregard_zeros=find(options==1);
if isempty(disregard_zeros),
  dz_opt=0;
else,
  dz_opt=1;
end;

if dz_opt,
  ftmpx=find(x==0);
  if ~isempty(ftmpx),
    ftmpx2=find(x~=0);
    for m=1:length(ftmpx2),
      tmpx(m)=x(ftmpx2(m));
      tmpy(m)=y(ftmpx2(m));
    end;
  else,
    tmpx=x;
    tmpy=y;
  end;
  clear x y
  x=tmpx(:); y=tmpy(:);
  ftmpy=find(y==0);
  if ~isempty(ftmpy),
    ftmpy2=find(y~=0);
    for m=1:length(ftmpy2),
      tmpx(m)=x(ftmpy2(m));
      tmpy(m)=y(ftmpy2(m));
    end;
  else,
    tmpx=x;
    tmpy=y;
  end;
  clear x y
  x=tmpx(:); y=tmpy(:);
end;

r=corrcoef(x,y);
c=polyfit(x,y,order);
yp=polyval(c,x);
SSE=sum((y-yp).^2);

if ra_opt,
  plot(y,x,'x',yp,x,'-')
else,
  plot(x,y,'x',x,yp,'-')
end;
msg=sprintf('r=%f (%f) SSE=%f',r(1,2),c(order),SSE);
title(msg),

if ul_opt,
  hold
  min_val=min([x;y]);
  max_val=max([x;y]);
  plot([min_val max_val],[min_val max_val])
  hold
end;

