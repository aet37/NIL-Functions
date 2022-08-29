function [y,cropii]=readOIS4(fname,imno,prec_type,vbin,cropii)
% Usage ... [y,cropii]=readOIS4(fname,imno,prec_type,vbin,cropii)

if nargin<5, cropii=[]; end;
if nargin<4, vbin=[]; end;
if nargin<3, prec_type=8; end;
if nargin<2, imno=1; end;

do_bin=1; do_crop=0;
if isempty(vbin), do_bin=0; vbin=[1 1 1]; end;
if ~isempty(cropii), do_crop=1; end;
if length(vbin)==1, vbin=[1 1 vbin]; end;

do_crop_select=0;
if isstr(cropii), do_crop_select=1; end;

dcim=readOIS3(fname,1);
if do_crop_select,
  tmpim=dcim;
  tmpfound=0;
  while(~tmpfound),
    figure(1), clf,
    show(tmpim), drawnow,
    disp('  select two locations...');
    tmploc=round(ginput(2));
    cropii=[sort([tmploc(1,2) tmploc(2,2)]) sort([tmploc(1,1) tmploc(2,1)])];
    if cropii(1)<1, cropii(1)=1; end;
    if cropii(3)<1, cropii(3)=1; end;
    if cropii(2)>size(tmpim,1), cropii(2)=size(tmpim,1); end;
    if cropii(4)>size(tmpim,2), cropii(4)=size(tmpim,2); end;
    cropii(2)=cropii(2)-rem(cropii(2)-cropii(1)+1,2);
    cropii(4)=cropii(4)-rem(cropii(4)-cropii(3)+1,2);
    disp(sprintf('  locs= %d %d %d %d',cropii));
    tmpmask=zeros(size(tmpim));
    tmpmask(cropii(1):cropii(2),cropii(3):cropii(4))=1;
    show(im_super(tmpim,tmpmask,0.5)), drawnow,
    tmpin=input('  locations ok? [1=yes, 0=no]: ');
    if tmpin==1, tmpfound=1; else, cropii=[]; end;
  end;
  do_crop=1;
end;

if length(imno)==1, 
  y=readOIS3(fname,imno);
  if prec_type==4, y=single(y);
  elseif prec_type==2, y=int16(y);
  end;
  if do_crop, y=y(cropii(1):cropii(2),cropii(3):cropii(4)); end;
  return;
elseif length(imno)>2,
  imno=imno(1:2);
  disp(sprintf('  adjusting to only %d to %d',imno(1),imno(2)));
end;

tmpim0=dcim;
if do_crop, tmpim0=tmpim0(cropii(1):cropii(2),cropii(3):cropii(4)); end;
if do_bin, tmpim0=imbin(tmpim0,vbin(1:2)); end;

if prec_type==4, 
  y=single(zeros(size(tmpim0,1),size(tmpim0,2),(imno(2)-imno(1)+1)/vbin(3)));
elseif prec_type==2,
  y=int16(zeros(size(tmpim0,1),size(tmpim0,2),(imno(2)-imno(1)+1)/vbin(3)));
else,
  y=zeros(size(tmpim0,1),size(tmpim0,2),(imno(2)-imno(1)+1)/vbin(3));
end;
size(y), [do_crop do_bin],
disp(sprintf('  output size= %d %d %d',size(y,1),size(y,2),size(y,3)));

found=0; cnt=0;
while(~found),
  cnt=cnt+1;
  disp(sprintf('  reading %02d: %d to %d',cnt+imno(1)-1,(cnt-1)*vbin(3)+imno(1),cnt*vbin(3)));
  tmpstk=readOIS3(fname,[(cnt-1)*vbin(3):cnt*vbin(3)-1]+imno(1));
  tmpim=mean(tmpstk,3);
  if do_crop, tmpim=tmpim(cropii(1):cropii(2),cropii(3):cropii(4)); end;
  if do_bin, tmpim=imbin(tmpim,vbin(1:2)); end;
  if prec_type==4,
    y(:,:,cnt)=single(tmpim);
  elseif prec_type==2,
    y(:,:,cnt)=int16(tmpim);
  else,
    y(:,:,cnt)=tmpim;
  end;
  if (cnt*vbin(3)+imno(1))>imno(2), found=1; end;
end;

