function writejpgs(im,fname,wl,smw)
% Usage writejpgs(im,fname,wl,smw)

if nargin<4, smw=[]; end;
if nargin<3, wl=[]; end;

if size(im,3)>1, do_many=1; else, do_many=0; end;
if isempty(wl), do_wl=0; else, do_wl=1; end;
if isempty(smw), do_sm=0; else, do_sm=1; end;

if do_many,
  if strcmp(fname(end-2:end),'jpg')|strcmp(fname(end-2:end),'JPG'),
    fname=fname(1:end-4);
  end;
end;

for mm=1:size(im,3),
  tmpim=im(:,:,mm);
  if do_sm, tmpim=im_smooth(tmpim,smw); end;
  if do_wl==0, wl=[min(min(tmpim)) max(max(tmpim))]; end;
  if do_wl, tmpim=imwlevel(tmpim,wl,1); end;
  if do_many, tmpname=sprintf('%s_%04d.jpg',fname,mm); else, tmpname=fname; end;
  imwrite(tmpim,tmpname,'JPEG','Quality',100);
end;
   

