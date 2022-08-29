function [y,imcrii,middir,imrot,imcr]=getROIproj(im,mask,edge,dirdir)
% Usage ... [proj,ii,dir,roi_rot,roi]=getROIproj(im,mask,edge)
%

if (length(mask)<5),
  mask_flag=0;
else,
  mask_flag=1;
end;

if (length(edge)<2),
  edge_flag=0;
else,
  edge_flag=1;
end;

if (edge_flag&mask_flag),
  [yy,midpix]=getedgedist(edge,mask);
  yyi_nan=find(isnan(yy));
  if (~isempty(yyi_nan)),
    disp(sprintf('  warning: mid-segment pixels may not be good (%d)',length(yyi_nan)));
    yyi_nn=find(~isnan(yy));
    yy=yy(yyi_nn);
    midpix=midpix(yyi_nn,:);
  end;
  if (isempty(midpix)),
    disp(sprintf('  warning: mid-segment pixels likely not good'));
    midpix=getimpix2(edge.*mask);
  end;
  if (isempty(midpix)),
    disp(sprintf('  warning: mid-segment pixels NOT GOOD, setting dir to 0 deg'));
    midpix=[]; middir=90;
  end;
else,
  midpix=[];
end;

if (~isempty(midpix)),
  n1=polyfit(midpix(:,1),midpix(:,2),1);
  err1=sum((midpix(:,2)-polyval(n1,midpix(:,1))).^2)/size(midpix,1);
  if (err1>2), disp(sprintf(' warning: segment may not be linear! (%f)',err1)); end;
  middir=atan(n1(1))*180/pi;
  %plot(midpix(:,1),midpix(:,2),'x',midpix(:,1),polyval(n1,midpix(:,1)),'d')
end;

if (~edge_flag),
  middir=edge(1);
end;
if (exist('dirdir')),
  middir=dirdir;
end;

if (edge_flag&mask_flag), 
  tmpim=edge+pixtoim(midpix,size(im));
  tmppix=getimpix2(tmpim.*mask);
  imcrii=[];
elseif ((~edge_flag)&mask_flag),
  tmpim=mask;
  tmpmaskpix=getimpix(mask);
  imcrii=[min(tmpmaskpix(:,1)) max(tmpmaskpix(:,1)) min(tmpmaskpix(:,2)) max(tmpmaskpix(:,2))];
elseif (~mask_flag),
  imcrii=mask;
  tmpim=zeros(size(im));
  tmpim(imcrii(1):imcrii(2),imcrii(3):imcrii(4))=1;
end;

if (isempty(imcrii)),
  imcrii=[min(tmppix(:,1)) max(tmppix(:,1)) min(tmppix(:,2)) max(tmppix(:,2))];
  if (isempty(imcrii)),
    disp(sprintf('  warning: using mask for cropping'));
    tmpmaskpix=getimpix(mask);
    imcrii=[min(tmpmaskpix(:,1)) max(tmpmaskpix(:,1)) min(tmpmaskpix(:,2)) max(tmpmaskpix(:,2))];
  end;
  if (abs(imcrii(2)-imcrii(1))<9)|(abs(imcrii(3)-imcrii(4))<9),
    disp(sprintf('  warning: edges may not be reliable for cropping, using mask'));
    tmpmaskpix=getimpix(mask);
    imcrii=[min(tmpmaskpix(:,1)) max(tmpmaskpix(:,1)) min(tmpmaskpix(:,2)) max(tmpmaskpix(:,2))];
  end;
end;

 
imcr_tmp=tmpim(imcrii(1):imcrii(2),imcrii(3):imcrii(4));
imcr=im(imcrii(1):imcrii(2),imcrii(3):imcrii(4));
imcr_minmax=[min(min(imcr)) max(max(imcr))];


imrot_tmp=imrotate(imcr_tmp,-middir,'bilinear','crop');
imrot=imrotate(imcr,-middir,'bilinear','crop');
%imrot_tmp=imrotate(imcr_tmp,-middir,'bilinear');
%imrot=imrotate(imcr,-middir,'bilinear');

y_tmp=sum(imrot_tmp);

imrot=imrot.*(imrot>(0.9*imcr_minmax(1)));
y=sum(imrot);
yi=sum(imrot~=0); yii=find(abs(yi)>0); yi(yii)=1./yi(yii);
y=y.*yi;
if (sum(isnan(y))),
  yi_nn=find(~isnan(y));
  disp(sprintf(' warning: removing zero entries (%d of %d)',length(y)-length(yi_nn),length(y)));
  y=y(yi_nn);
  y_tmp=y_tmp(yi_nn);
end;
yii2=find(abs(y)>(0.9*imcr_minmax(1)));
y=y(yii2);
y_tmp=y_tmp(yii2);

x=[1:length(y)];
%keyboard,

if (nargout==0),
  figure(1)
  subplot(221)
  show(im)
  if (mask_flag),
    subplot(222)
    show(mask)
  end;
  if (edge_flag),
    subplot(224)
    show(imcr_tmp)
  end;
  subplot(223)
  show(imcr)

  figure(2)
  subplot(221)
  show(imrot,imcr_minmax)
  subplot(222)
  show(imrot_tmp)
  subplot(212)
  plot(y)
  title(sprintf('[%d %d %d %d]   dir= %f',imcrii(1),imcrii(2),imcrii(3),imcrii(4),middir));
end;

