function [im,cm,cbh]=im_overlay5(im1,im2,ncolors,cmap2,cmap1,do_cbar)
% Usage ... [im,cm,cbh]=im_overlay5(im1,im2,ncolors,cmap2,cmap1,cbar)

do_cbar=0;

if ~exist('ncolors','var'), ncolors=[]; end;
if isempty(ncolors), ncolors=[128]; end;
if isstr(ncolors), ncolors=[128]; do_cbar=1; end;
if length(ncolors)==1, ncolors(2)=max(im2(:)); end;

im1=im1-min(im1(:)); im1=im1/max(im1(:));
im2=im2-min(im2(:)); im2=im2/max(im2(:));
tmpi2=find(im2>10*eps);

im1new=round(im1*(ncolors(1)-1))+1;
im2new=round(im2*(ncolors(2)-1))+1;

if ~exist('cmap1','var'), cmap1=[]; end;
if isstr(cmap1), cmap1=[]; do_cbar=1; end;
if ~exist('cmap2','var'), cmap2=[]; end;
if isstr(cmap2), cmap2=[]; do_cbar=1; end;
if isempty(cmap1),
  cmap1=[0:ncolors(1)-1]/(ncolors(1)-1);
  cmap1=[cmap1(:) cmap1(:) cmap1(:)];
end;
if isempty(cmap2),
  tmpmap2=colormap(jet(256));
  tmpmap2i=round([1:ncolors(2)]*(256/ncolors(2)));
  cmap2=tmpmap2(tmpmap2i,:);
end;

im1new(tmpi2)=im2new(tmpi2)+ncolors(1);

map1new=[cmap1;cmap2(1:ncolors(2),:)];

image(im1new), axis('image'), colormap(map1new),

if do_cbar,
  tmphh=colorbar;
  set(tmphh,'Limits',[ncolors(1)+1 sum(ncolors)]);
  cbh=tmphh;
end;

