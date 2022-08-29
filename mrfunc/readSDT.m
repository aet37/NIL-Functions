function vol=readSDT(fname,dim,bytes,complexflag)
% Usage ... vol=readSDT(fname,dim,bytes,complexflag)

if nargin<4, complexflag=0; end;
if nargin<3, bytes=2; end;

if ~isstr(bytes),
  if (bytes==2),
    bytename='short';
  elseif (bytes==4),
    bytename='float';
  else,
    error(sprintf('Selected format type not supported yet (%d)',bytes));
  end;
else,
  bytename=bytes;
end;


fid=fopen(fname,'r','b');
if (fid<3),
  error(sprintf('Could not open file %s',fname));
end;

if length(dim)==2,
  vol=fread(fid,dim,bytename);
elseif length(dim)==3,
  for mm=1:dim(3),
    vol(:,:,mm)=fread(fid,dim(1:2),bytename);
  end;
elseif length(dim)==4,
  for nn=1:dim(4), for mm=1:dim(3),
    vol(:,:,mm,nn)=fread(fid,dim(1:2),bytename);
  end; end; 
else,
  error(sprintf('Invalid dimension for file (%d)',length(dim)));
end;


