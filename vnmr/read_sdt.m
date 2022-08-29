function y=read_sdt(fname,imdim,imno,imprec)
% Usage ... y=read_sdt(fname,imdim,imno,imprec)
%
% imdim default in 64x64
% imno default is 'all'
% prec default is 'float'

if nargin<4, prec='float'; end;
if nargin<3, imno=1; end;
if nargin<2, imdim=[64 64]; end;

do_readall=0;
if isstr(imno), do_readall=1; end;
if length(imdim)==4, do_readall=0; end;

if strcmp(prec,'double'),
  nb=8;
elseif strcmp(prec,'float')|strcmp(prec,'int32')|strcmp(prec,'uint32'),
  nb=4;
elseif strcmp(prec,'int16')|strcmp(prec,'uint16'),
  nb=2;
elseif strcmp(prec,'uint8')|strcmp(prec,'int8')|strcmp(prec,'char'),
  nb=1;
else,
  nb=4;
end;

noff=0;
fid=fopen(fname,'r');

if do_readall,
  fseek(fid,0,'eof');
  ns=ftell(fid);
  fseek(fid,0,'bof');
  npl=floor(ns/(nb*prod(imdim)));
  disp(sprintf('  reading %s (%d): %s',fname,ns,num2str([imdim,npl])));
  y=fread(fid,prod([imdim,npl]),prec);
  y=reshape(y,imdim);
else,
  fseek(fid,nb*prod(imdim)*(imno-1)+noff,'bof');
  y=fread(fid,prod(imdim),prec);
  y=reshape(y,imdim);
end;


fclose(fid);

