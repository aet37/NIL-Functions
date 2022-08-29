function vol=getanalyzevol(analyzeroot,volno,info)
% Usage ... vol=getanalyzevol(analyzeroot,vol#,info)
%
% info= [xdim ydim zdim]

if ~exist('volno'), volno=0; end;

if (volno==0)|(nargin==1),
  imgfile=sprintf('%s.img',analyzeroot);
  hdrfile=sprintf('%s.hdr',analyzeroot);
else,
  imgfile=sprintf('%s_%04d.img',analyzeroot,volno);
  hdrfile=sprintf('%s_%04d.hdr',analyzeroot,volno);
end;

if nargin<3,
  hdr=getanalyzeinfo(hdrfile);
  info=[hdr(1) hdr(2) hdr(3)];
  if hdr(5)==4, info(4)=2; end;
  if hdr(5)==2, info(4)=1; end;
end;
if length(info)<4, info(4)=2; end;

if info(4)==1,
  type='char';
else,
  type='short';
end;

fid=fopen(imgfile,'r');
if (fid<3), error(['Could not open file ',imgfile]); end;

for m=1:info(3),
  [im,cnt]=fread(fid,info(1:2),type);
  if (cnt~=prod(info(1:2))), 
    msg=sprintf('Could not read image %d of %d in %s',m,info(3),imgfile);
    error(msg) 
  end;
  vol(:,:,m)=im;
end;

fclose(fid);

