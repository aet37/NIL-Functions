function [f,thr]=im_topthr(image,topn,topbottom)
% Usage ... [f,thr]=im_topthr(image,topn,topbottom)

% average search algorithm

topbottom=1;

immin=min(min(image));
immax=max(max(image));

found=0;
while(~found),
  thr=immax-0.5*(immax-immin);
  [nv,nv2]=find(image>thr);
  %thr, length(nv),
  if length(nv)==topn,
    found=1;
  elseif length(nv)>topn,
    found=0;
    immin=thr;
  else,
    found=0;
    immax=thr;
  end;
end;

f=image>thr;

