function [y,dimage]=readOIS(fname,aa)
% Usage ... y=readOIS(fname,aa)
%
% If a range of images is selected, a 3D set is returned


verbose_flag=1;

fid=fopen(fname,'rb','l');
if (fid<3), error('Could not open file!'); end;

nx=fread(fid,1,'short'); %width
ny=fread(fid,1,'short'); %height
nf=fread(fid,1,'short'); %frames
nc=fread(fid,1,'short'); %not used
if (verbose_flag),
  disp(sprintf('  xdim= %d, ydim= %d, nfr= %d, ncam= %d',nx,ny,nf,nc));
end;

if (rem(aa,nf)),
  error('Average number of images is not consistent, please change');
end;

dimage=fread(fid,[nx ny],'short');
%fpos=ftell(fid);

%if (nargin==1), im=0; end;
%if (isstr('im')),
%  if (im=='all'),
%    im=[1:nf];
%  elseif (im=='first'),
%    im=1;
%  elseif (im=='last'),
%    im=nf;
%  else,
%    disp('Returning reference image...')
%    im=0;
%  end;
%end;

cnt=0; tmp=0;
for mm=1:nf,
  tmp=tmp+fread(fid,[nx ny],'int8');
  if (~rem(aa,mm)),
    cnt=cnt+1;
    y(:,:,cnt)=tmp/aa+dimage;
    tmp=0;
  end;
end;

fclose(fid);

