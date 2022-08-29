function [y2,yi2,y1,yi1]=rect2r(ww,ang,lt,imsize)
% Usage ... [yim,yi,xim,xi]=rect2r(w,ang,lt,imsize)

lt0=-[floor(ww(1)/2) floor(ww(2)/2)];
y1=rect2d(ww(1),ww(2),0,0,imsize(1),imsize(2));
[i1,i2]=find(y1>eps);
yi1=[i1(:) i2(:)];

yi1=yi1+ones(length(i1),1)*lt0;

ang=ang*(pi/180);
rotm=[cos(ang) -sin(ang); sin(ang) cos(ang)];
yi2=yi1*rotm+ones(length(i1),1)*lt;

y2=zeros(size(y1));
for mm=1:length(i1),
  tmpi1=round(yi2(mm,1));
  tmpi2=round(yi2(mm,2));
  if ((tmpi1>0)&(tmpi2>0)&(tmpi1<=imsize(1))&(tmpi2<=imsize(2))),
    y2(tmpi1,tmpi2)=1;
  end;
end;

