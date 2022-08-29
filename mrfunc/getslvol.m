function f=getslvol(path,volno,imsize,ext)
% Usage ... f=getslvol(path,volno,[imsize volsize])

if (nargin<4), ext=''; end;

if length(imsize)==3,
  i1=1;
  iend=imsize(3);
else,
  i1=imsize(3);
  iend=imsize(4);
end;

for m=i1:iend,
  if volno<1000,
    fname=sprintf('%ssl%d.%s%03d',path,m,ext,volno);
  else,
    fname=sprintf('%ssl%d.%s%04d',path,m,ext,volno);
  end;
  %disp(fname);
  f(:,:,m)=readim(fname,imsize(1:2));
end;

