function c=mygraycmap(ncolors,scaling)
% Usage ... c=mygraycmap(ncolors,scaling)

if (nargin<2),
  scaling=(1/(ncolors-1))*ones([1 ncolors]);
end;

c(1,:)=[0 0 0];
for m=2:ncolors,
  c(m,:)=c(m-1,:)+scaling(m);
end;

