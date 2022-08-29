function im=matchpixl(pixlist,xlist,dim)
% Usage ... f=matchpixl(pixlist,xlist,dim)
%
% Makes a new image of dimensions dim=[xdim ydim]
% where the (x,y) value corresponds to the value in
% the same row as in xlist. The pixel list (pixlist)
% must be x and y in columns and the list in rows.

if nargin<3,
  im=zeros([2^ceil(log2(max(max(pixlist)))) 2^ceil(log2(max(max(pixlist))))]);
else,
  im=zeros([dim(1) dim(2)]);
end;
if nargin<2,
  xlist=zeros(size(pixlist,1),1);
end;

for m=1:size(pixlist,1),
  im(pixlist(m,1),pixlist(m,2))=xlist(m);
end;
