function [imall,mycmap,im1,im2]=im_overlay4(im1,im2,ncolors,thesecolors)
% function [y,cmap]=im_overlay4(im1,im2,ncolors,thesecolors)
%
% im1: background gray-scale image (not-scaled)
% im2: foreground jet-scale image (indexed and min ignored)
% ncolors: 256-default, other options= 'alt','alt-all'

verbose_flag=0;
do_alt=0;

if length(size(im2))==3,
  im2_orig=im2;
  im2_tmp=zeros(size(im2,1),size(im2,2));
  for oo=1:size(im2,3), im2_tmp(find(im2(:,:,oo)))=oo; end;
  im2=im2_tmp;
end;
if iscell(im2),
  im2_orig=im2;
  im2_tmp=zeros(size(im2,1),size(im2,2));
  for oo=1:length(im2), im2_tmp(find(im2{oo}))=oo; end;
  im2=im2_tmp;
end;

if nargin<3,
  %ncolors=ceil(max(im2(:)));
  ncolors=256+floor(max(im2(:)));
  %ncolors=2^(floor(log(max(im2(:)))/log(2))+2);
  %if verbose_flag, disp(sprintf('  ncolors= %d',ncolors)); end;
end;
if nargin==3,
  if ischar(ncolors),
    if strcmp(ncolors,'alt'),
      do_alt=1;
      ncolors=256;
    elseif strcmp(ncolors,'alt-all'),
      do_alt=2;
      ncolors=256;
    end;
  end;
end;


idxim2_flag=0;
%if max(im2(:))>(ncolors/2),
%  idxim2_flag=1;
%end;

im1=im1-min(im1(:));
im1=im1/max(im1(:));

im2=im2-min(im2(:));
if idxim2_flag, im2=round(ncolors*im2/max(im2(:))); end;
nindex=max(im2(:));

ngray=ncolors-nindex;
njet=nindex;

mygray=[0:ngray-1]'/(ngray-1);
mygray=[mygray(:) mygray(:) mygray(:)];
tmpjet=colormap(jet(ncolors)); 
if njet~=0,
  tmpjet=tmpjet(1:floor(size(tmpjet,1)/njet):end,:);
  myjet=tmpjet(1:njet,:);
end;
if nargin==4,
  mycmap=[thesecolors;mygray];
else,
  if njet==0,
    mycmap=mygray;
  else,
    mycmap=[myjet;mygray];
  end;
end;
if (nargout==0),
  if verbose_flag,
    disp(sprintf('  #colors= %d (%d,%d)',size(mycmap,1),njet,ngray));
  end;
  %myjet,
end;

im1ind=round(im1*(ngray-1))+1;
imall=im1ind+njet; 
imall(find(im2>0))=im2(find(im2>0));

if do_alt,
  for mm=1:8,
    if rem(mm,2),
      image(imall), colormap(mycmap), axis('image'), drawnow, pause(0.25);
    else,
      imagesc(im1), colormap(gray), axis('image'), drawnow, pause(0.25);
    end;
  end;
else,
  image(imall), colormap(mycmap), axis('image'),
end;

if nargout==0,
  clear imall
end;

if nargout==1,
  y=imall;
  clear imall
  imall.cim=y;
  imall.cmap=mycmap;
  imall.ov_colors=myjet;
end;


