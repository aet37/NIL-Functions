function y=rot3d(x,xangle,yangle,zangle)
% Usage ... y=rot3d(x,xangle,yangle,zangle)
%
% x is a 3 column coordinate and angles are in degrees

if nargin==2,
  yangle=xangle(2);
  zangle=xangle(3);
  tmp=xangle(1)
  clear xangle
  xangle=tmp;
end;

zangle=zangle*(pi/180);
xangle=xangle*(pi/180);
yangle=yangle*(pi/180);

rotmz=[cos(zangle) -sin(zangle) 0;sin(zangle) cos(zangle) 0;0 0 1];
rotmx=[1 0 0; 0 cos(xangle) -sin(xangle);0 sin(xangle) cos(xangle)];
rotmy=[cos(yangle) 0 -sin(yangle);0 1 0;sin(yangle) 1 cos(yangle)];

if size(x,1)==1,
    tmp1=(rotmz*(x.')).';
    tmp2=(rotmx*(tmp1.')).';
    y=(rotmy*(tmp2.')).';
else,
  for m=1:size(x,1),
    tmp1=(rotmz*(x(m,:).')).';
    tmp2=(rotmx*(tmp1.')).';
    y(m,:)=(rotmy*(tmp2.')).';
  end;
end;

