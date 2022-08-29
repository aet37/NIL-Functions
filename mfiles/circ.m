function y=circ(inmat,r0,c0,rad,val)
% Usage ... y=circ(inmat,r0,c0,rad,val)

if (nargin<5), val=1; end;
y=ellipse(inmat,r0,c0,rad,rad,0,val);

