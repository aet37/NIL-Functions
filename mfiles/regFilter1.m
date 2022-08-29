function ee=regFilter1(x0,f,parms,parms2fit,y)
% Usage ... e = regFilter(x0,A,parms,parms2fit,y-optional)

if ~isempty(x0),
  parms(parms2fit)=x0;
end;
y1=zeros(size(f(:,1)));
for mm=1:size(f,2),
  y1=y1+parms(mm)*f(:,mm);
end;
  
if nargin<5,
  ee=y1;
else,
  ee=y-y1;
end;
