function f=binary_map(pixlist,imsize)
% Usage ... f=binary_map(pixlist,imsize)
%
% Pixlist is a two column matrix acquired
% when the matrix is transposed.

im=zeros(imsize);
for m=1:length(pixlist),
  im(pixlist(m,1),pixlist(m,2))=1;
end;

f=im;
