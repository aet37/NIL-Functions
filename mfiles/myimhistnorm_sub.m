function [y,ys]=myimhistnorm_sub(im,parms)
% Usage ... y=myimhistnorm_sub(im,parms)

% assign the center pixel the value of the normalized histogram in the
% sub-region, do this for all pixels in the image

ww=parms(1);
skp=parms(2);
if length(parms)==3, thr=parms(3); end;

nx=ceil((size(im,1)-ww)/skp)+1;
ny=ceil((size(im,2)-ww)/skp)+1;
yy=zeros(size(im,1),size(im,2),nx*ny);
y=zeros(size(im));

cnt=0;
for mm=1:nx,
  for nn=1:ny,
    cnt=cnt+1;
    tmpi(1)=(mm-1)*skp+1;
    tmpi(2)=tmpi(1)+ww-1;
    tmpj(1)=(nn-1)*skp+1;
    tmpj(2)=tmpj(1)+ww-1;
    if tmpi(2)>size(im,1),
      tmpi(2)=size(im,1); tmpi(1)=tmpi(2)-ww+1;
    end;
    if tmpj(2)>size(im,2),
      tmpj(2)=size(im,2); tmpj(1)=tmpj(2)-ww+1;
    end;
    tmpim=im(tmpi(1):tmpi(2),tmpj(1):tmpj(2));
    tmpimhn=myimhistnorm(tmpim);
    tmpimhn=tmpimhn-min(tmpimhn(:));
    tmpimhn=tmpimhn/max(tmpimhn(:));
    yy(tmpi(1):tmpi(2),tmpj(1):tmpj(2),cnt)=tmpimhn;
  end;
end;

for mm=1:size(im,1), for nn=1:size(im,2),
  tmpii=find(yy(mm,nn,:)>0);
  if ~isempty(tmpii), y(mm,nn)=mean(yy(mm,nn,tmpii),3); end;
end; end;

if length(parms)==3, ys=sum(yy>thr,3); end;
