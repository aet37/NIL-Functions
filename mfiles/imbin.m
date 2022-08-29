function y2=imbin(x,bsize)
% Usage y=imbin(x,binsize)

if bsize==1;
  y2=x;
  if nargout==0, show(y2), clear y2, end;
  return;
end

if length(bsize)==1, bsize=[1 1]*bsize; end;

imdim=size(x);
iend1=floor(imdim(1)/bsize(1))*(bsize(1));
iend2=floor(imdim(2)/bsize(2))*(bsize(2));

y=x(1:bsize(1):iend1,:);
%[bsize iend1 iend2],
for mm=2:bsize(1),
  y=y+x(mm:bsize(1):iend1,:);
end;
y2=y(:,1:bsize(2):iend2);
for mm=2:bsize(2),
  y2=y2+y(:,mm:bsize(2):iend2);
end;

if isfloat(x),
  y2=y2/prod(bsize(1:2));
end;

if nargout==0,
  show(y2)
  clear y2
end;

