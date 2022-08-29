function f=getslvol(path,slno,ntcs,imsize,ext)
% Usage ... f=getslvol(path,slno,ntcs,[imsize volsize])

if (nargin<5),
  ext=''; 
else,
  ext=[ext,'.'];
end;

for m=1:ntcs,
  if m<1000,
    fname=sprintf('%ssl%d.%s%03d',path,slno,ext,m);
  else,
    fname=sprintf('%ssl%d.%s%04d',path,slno,ext,m);
  end;
  %disp(fname);
  f(:,:,m)=readim(fname,imsize(1:2));
end;

