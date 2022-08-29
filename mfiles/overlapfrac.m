function y=overlapfrac(x1,x2,mask)
% Usage ... y=overlapfrac(x1,x2,mask)

if nargin==3,
  x1=x1.*mask;
  x2=x2.*mask;
end;

yo=((x1(:)>0)&(x2(:)>0));
y=2*sum(yo(:))/(sum(x1(:))+sum(x2(:)));

if (nargout==0)&(length(size(x1))==2),
  subplot(221)
  show(x1)
  xlabel('x1')
  subplot(222)
  show(x2)
  xlabel('x2')
  subplot(223)
  show(yo)
  xlabel(sprintf('x1 and x2 overlap=%.3f',y))
end;

