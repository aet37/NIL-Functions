function c=myhotcmap(ncolors,scaling)
% Usage ... c=myhotcmap(ncolors,scaling)

if (nargin<2),
  scaling=(1/(ncolors-1))*ones([1 ncolors]);
end;

c(1,:)=[0 0 0];
for m=2:ncolors,
  if (m<=(ncolors/3+1)),
    hscale=[3*scaling(m) 0 0];
  elseif (m<=(2*ncolors/3+1)),
    hscale=[0 3*scaling(m) 0];
  else,
    hscale=[0 0 3*scaling(m)];
  end;
  c(m,:)=c(m-1,:)+hscale;
end;

