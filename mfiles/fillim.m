function f=fillim(image)
% Usage ... f=fillim(image)
% Image must be closed structure to be filled and binary.

[ir,ic]=size(image);

in=0; out=1;
for m=1:ir, for n=1:ic,
  if (image(m,n)),
    if (~in) in=1; tmp=n; end;
    if (~out) out=1; in=0; end;
  else,
    if (in), image(m,n)=1; out=0; end;
  end;
  %if (in&(n==ic)),
  %  for o=tmp:ic, image(m,o)=0; end;
  %end;
end; end;

f=image;

if (nargout==0),
  show(f);
  axis('on');
  grid;
end;
