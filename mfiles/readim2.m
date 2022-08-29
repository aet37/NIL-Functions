function im=imread2(fname,N)
% Usage ... im=imread2(fname,N)

if nargin==1,
  im.filename=fname;
  im.data=imread(fname);
  im.info=imfinfo(fname);
else,
  if length(N)==1,
    im.filename=fname;
    im.data=imread(fname,N);
    im.info=imfinfo(fname,N);
  else,
    error('No more than one entry currently supported for N');
  end;
end;

