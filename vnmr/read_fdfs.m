function imgs=read_fdfs(fdfpath,xyshift)
% Usage ... imgs=read_fdfs(fdfpath,xyshift)

do_shift=0;
do_show=0;

if exist('xyshift'),
  do_shift=1;
end;
if nargout==0,
  do_show=1;
end;

tmppath=sprintf('%s/*.fdf',fdfpath); 
ff=dir(tmppath); 

if length(ff)>0,
for mm=1:length(ff),
  tmpname=sprintf('%s/%s',fdfpath,ff(mm).name);
  tmpim=read_fdf(tmpname);
  if (do_shift), tmpim=imshift2(tmpim,xyshift(1),xyshift(2)); end;
  if (do_show), tmpim=tmpim'; end;
  imgs(:,:,mm)=tmpim;
end;
else, imgs=0; end;

if do_show,
  tile3d(imgs);
end;

