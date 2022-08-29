function [xr,yr,y,middir,imcrii,yy]=calcRadius(im,mask,edge,middir,imcrii,projm)
% Usage ... [xr,yr,ydata,middir,imcrii,yy]=calcRadius(im,mask,edge,middir,imcrii,projm)
%

[yy,midpix]=getedgedist(edge,mask);
yyi_nan=find(isnan(yy));
if (~isempty(yyi_nan)),
  disp(sprintf(' warning: mid-segment pixels may not be good (%d)',length(yyi_nan)));
  yyi_nn=find(~isnan(yy));
  yy=yy(yyi_nn);
  midpix=midpix(yyi_nn,:);
end;

if (nargin<4),
  n1=polyfit(midpix(:,1),midpix(:,2),1);
  err1=sum((midpix(:,2)-polyval(n1,midpix(:,1))).^2)/size(midpix,1);
  if (err1>2), disp(sprintf(' warning: segment may not be linear! (%f)',err1)); end;
  middir=atan(n1(1))*180/pi;
  %plot(midpix(:,1),midpix(:,2),'x',midpix(:,1),polyval(n1,midpix(:,1)),'d')
end;

tmpim=edge+pixtoim(midpix,size(im));
tmppix=getimpix2(tmpim.*mask);

if (nargin<5),
  imcrii=[min(tmppix(:,1)) max(tmppix(:,1)) min(tmppix(:,2)) max(tmppix(:,2))];
end;

imcr_tmp=tmpim(imcrii(1):imcrii(2),imcrii(3):imcrii(4));
imcr=im(imcrii(1):imcrii(2),imcrii(3):imcrii(4));
imcr_minmax=[min(min(imcr)) max(max(imcr))];

imrot_tmp=imrotate(imcr_tmp,-middir,'bilinear','crop');
imrot=imrotate(imcr,-middir,'bilinear','crop');

y_tmp=sum(imrot_tmp);
y=sum(imrot)./sum(imrot~=0);
if (sum(isnan(y))),
  yi_nn=find(~isnan(y));
  disp(sprintf(' warning: removing zero entries (%d of %d)',length(y)-length(yi_nn),length(y)));
  y=y(yi_nn);
  y_tmp=y_tmp(yi_nn);
end;
y=y(find(y>(0.9*imcr_minmax(1))));
x=[1:length(y)];
%keyboard,

% fit y
if (nargin>6),
  li=ceil(0.2*length(x)); li=[[1:li] [li-length(x):length(x)]];
  ll=polyfit(x(li),y(li),1);
  projm=ll(1);
end;
xg=[length(y)*0.3 length(y)/2 -0.5*(max(y)-min(y)) 0.95*max(y) projm];
xub=[length(y) length(y) max(y) max(y) 10];
xlb=[0 1 -max(y) 1.001*min(y) -10];
opt2=optimset('lsqnonlin');
opt2.TolFun=1e-10;
opt2.TolX=1e-10;
opt2.MaxIter=1000;

xr=lsqnonlin(@cylprojy,xg,xlb,xub,opt2,x,y);
yr=cylprojy(xr,x);


if (nargout==0),
  figure(1)
  subplot(221)
  show(imcr)
  title(sprintf('crop= [%d %d %d %d]',imcrii(1),imcrii(2),imcrii(3),imcrii(4)));
  subplot(222)
  show(imcr_tmp)
  subplot(223)
  show(imrot,imcr_minmax)
  subplot(224)
  show(imrot_tmp)
  figure(2)
  subplot(311)
  plot(midpix(:,1),midpix(:,2),'x')
  if (exist('middir','var')),
    title(sprintf('middir= %f',middir));
    %hold('on'),
    %plot(midpix(:,1),polyval(n1,midpix(:,1)),'rd')  
    %hold('off'),
  end;
  subplot(312)
  plot([yr;y]')
  subplot(313)
  plot(y_tmp)
  %pause,
end;

