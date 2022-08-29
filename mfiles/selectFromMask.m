function [y,yim]=selectFromMask(mask,im)
% Usage ... y=selectFromMask(mask,im)
%
% mask has to be labeled mask (not binary), use bwlabel if not
% im is background image for display. click outside the image to exit

warning('off'),

if nargin<2, im=zeros(size(mask)); end;

tmpmask=double(mask>0);

clf,
tmpfound=0;
while(~tmpfound),
  im_overlay4(im,tmpmask), drawnow,
  tmploc=round(ginput(1));
  if (tmploc(2)<1)|(tmploc(2)>size(mask,1)),
    tmpfound=1;
  elseif (tmploc(1)<1)|(tmploc(2)>size(mask,2)),
    tmpfound=1;
  else,
    tmpii=mask(tmploc(2),tmploc(1));
    tmpii2=tmpmask(tmploc(2),tmploc(1));
    %disp(sprintf('  [%d, %d]= %d %d',tmploc(1),tmploc(2),tmpii,tmpii2));
    if tmpii>0,
      if tmpii2==1,
        tmpmask(find(mask==tmpii))=2;
      else,
        tmpmask(find(mask==tmpii))=1;
      end;
    end;
  end;
end;

yim=(tmpmask==2);

cnt=0;
for mm=1:max(mask(:)),
  if sum(sum(yim.*(mask==mm))),
    cnt=cnt+1;
    y(cnt)=mm;
  end;
end;

