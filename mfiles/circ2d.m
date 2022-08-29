function y=circ2d(inmat,r0,c0,rad,val)
% Usage ... y=circ2d(inmat,r0,c0,rad)

if (nargin<5), val=1; end;

y=inmat;
for mm=1:size(y,1), for nn=1:size(y,2),
  if sqrt((r0-mm)^2 + (c0-nn)^2)<=rad,
    y(mm,nn)=y(mm,nn)+val;
  end;
end; end;

if nargout==0,
  show(y'),
end;

