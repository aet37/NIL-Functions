function y=myaffine2d_f(im1,x0,y0,r0,sx0,sy0,imsize,mask)
% Usage ... y=myaffine2d_f(im1,x0,y0,r0,sx0,sy0,imresize,mask)
%
% Uses translation, rotation and scaling of im1 
% if im2 is included in imresize then im1 is rescaled to match im2 first

verbose_flag=2;

if nargin<8, do_mask=0; else, do_mask=~isempty(mask); end;
if nargin<7, imsize=[]; end;

if length(x0)==5,
  if nargin>2, imsize=y0; end;
  if nargin>3, do_mask=1; mask=r0; end;
  y0=x0(2); r0=x0(3); sx0=x0(4); sy0=x0(5);
  x0=x0(1);
end;

if length(imsize)>2,
  im2=imsize;
  imsize=size(im2);
  do_opt=1;
  if do_mask==0, do_mask=2; end;
else,
  do_opt=0;
end;

if length(imsize)==2,
  %disp(sprintf('  resizing image (%d)',do_opt));
  xi1=([0:size(im1,1)-1]-ceil((size(im1,1)-1)/2))/ceil((size(im1,1)-1)/2);
  yi1=([0:size(im1,2)-1]-ceil((size(im1,2)-1)/2))/ceil((size(im1,2)-1)/2);
  nxi=([0:imsize(1)-1]-ceil((imsize(1)-1)/2))/ceil((imsize(1)-1)/2);
  nyi=([0:imsize(2)-1]-ceil((imsize(2)-1)/2))/ceil((imsize(2)-1)/2);
  %keyboard,
  [xx1,yy1]=meshgrid(xi1(:),yi1(:));
  [nx1,ny1]=meshgrid(nxi(:),nyi(:));
  im1rs=interp2(xx1,yy1,im1',nx1,ny1)';
  im1orig=im1;
  im1=im1rs;
  im1(find(isnan(im1)))=0;
  %im2rs=interp2(nx1,ny1,im2',xx1,yy1)';
  %im2orig=im2;
  %im2=im2rs;
end;

y1=imshift2(im1,y0,x0);

xi1=([0:size(im1,1)-1]-ceil((size(im1,1)-1)/2))/ceil((size(im1,1)-1)/2);
yi1=([0:size(im1,2)-1]-ceil((size(im1,2)-1)/2))/ceil((size(im1,2)-1)/2);

[xx1,yy1]=meshgrid(xi1(:),yi1(:));
[xs1,ys1]=meshgrid(xi1(:)*sy0,yi1(:)*sx0);
y2=interp2(xx1,yy1,y1',xs1,ys1)';
y2(find(isnan(y2)))=0;

y3=rot2d_f(y2,r0);

y=y3;

if do_opt,
  y=y-im2;
  if (nargout==0)|(verbose_flag==2), show(y), drawnow, end;
  if do_mask==1,
    y=y(find(mask));
  %elseif do_mask==2,
  %  [nx,ny]=size(y);
  %  mask=zeros(nx,ny);
  %  nx0=round(0.2*nx); ny0=round(0.2*ny);
  %  mask(nx0+1:end-nx0,ny0+1:end-ny0)=1;
  %  y=y(find(mask));
  end;
  if verbose_flag,
    disp(sprintf('  err(%d)= %f  [%.3f, %.3f, %.3f, %.3f, %.3f]',do_mask,mean(y(:).^2),x0,y0,r0,sx0,sy0));
  end;
end;

if nargout==0,
  clf,
  subplot(221), show(im1), xlabel('Original'),
  subplot(222), show(y1), xlabel('Translate'),
  subplot(223), show(y2), xlabel('Scale'),
  subplot(224), show(y3), xlabel('Rotate & Final'),
  clear
end;


