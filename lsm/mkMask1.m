function [tmpmaskv,tmpmaski]=mkMask1(im,parms)
% Usage ... y=mkMask1(im,parms)
% 
% Uses mouse clicks to define a mask over an image

if nargin==1, parms=[3]; end;
dwid=parms(1);

tmpmaskv=zeros(size(im));

mm=1;
tmpdone=0;
while(~tmpdone),
  tmpmask=tmpmaskv(:,:,mm);
  tmpmask2=imdilate(tmpmask,strel('disk',dwid));
  tmpfound=0;
  while(~tmpfound),
    tmpin='';
    im_overlay4(im(:,:,mm),tmpmask2), xlabel(num2str(mm)),
    [tmppix1,tmppix2,tmpbut]=ginput(1);
    tmppix1=round(tmppix1); tmppix2=round(tmppix2);
    if tmpbut==3,
      for nn=1:2, 
        show(im(:,:,mm)), pause(0.3), im_overlay4(im(:,:,mm),tmpmask), pause(0.3),
      end;
    elseif (tmppix1>size(im,2))|(tmppix2>size(im,1)),
      tmpin='n';
      tmpfound=1;
    elseif (tmppix1<1)|(tmppix2<1),
      tmpfound=1;
    else,
      tmpmask(tmppix2,tmppix1)=1-tmpmask(tmppix2,tmppix1);
      tmpmask2=imdilate(tmpmask,strel('disk',dwid));
      im_overlay4(im(:,:,mm),tmpmask2)
    end;
  end;
  [tmpmaski{mm},tmpmaskj{mm}]=find(tmpmask);
  tmpmaskv(:,:,mm)=tmpmask;
  if length(tmpin)>0,
    tmpin=input(sprintf('  Select [n:next, b:back, r:reset, g#:goto#, x:done] (%d/%d): ',mm,size(im,3)),'s'); 
  end;
  if strcmp(tmpin(1),'n'),
    mm=mm+1;
  elseif strcmp(tmpin(1),'b'),
    mm=mm-1;
  elseif strcmp(tmpin(1),'r'),
    tmpmask=zeros(size(tmpmask));
    tmpmask2=tmpmask;
  elseif strcmp(tmpin(1),'g'),
    if length(tmpin)>1,
      mm=round(str2num(tmpin(2:end)));
    else,
      mm=input('  enter sl#: ');
    end;
  else,
    tmpdone=1;
  end;
  if mm<1, mm=1; end;
  if mm>size(im,3), mm=size(im,3); tmpdone=1; end;
end;

