function im=tri2d(wx,wy,xloc,yloc,xdim,ydim,uplow,uplow2)
% Usage ... f=tri2d(wx,wy,xloc,yloc,xdim,ydim,uplow)
% All units in pixels


if abs(uplow)>99,
  x1=wx; x2=xloc;
  y1=wy; y2=yloc;
  wx=x2-x1;
  wy=y2-y1;
  xloc=x1;
  yloc=y1;
  if (nargin>7),
    x3=uplow;
    y3=uplow2;
    if (x3>=x1)&(x3<x2),
      uplow=1;
    else,
      uplow=-1;
    end;
  end; 
end;

rect2d=ones(wx,wy);
im=zeros(xdim,ydim);

xx=[1:wx]-1;
yy=[1:wy]-1;
xy=round((wy/wx)*xx(:));

if (uplow>0),
  for mm=1:wx,
    rect2d(mm,:)=(yy>=xy(mm));
  end;
elseif (uplow<0),
  for mm=1:wx,
    rect2d(mm,:)=(yy<=xy(mm));
  end;
end;

if (abs(uplow)==2),
  rect2d=imflip(rect2d,2);
end;

im(xloc:xloc+wx-1,yloc:yloc+wy-1)=rect2d;

