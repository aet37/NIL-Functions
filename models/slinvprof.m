function [prof,yys]=slinvprof(regsl,invsl,fov,loc,orthflag)
% Usage ... [prof]=slinvprof(regsl,invsl,fov,loc,orthflag)

if (nargin<5), orthflag=0; end;

xdim=size(regsl,1);
ydim=size(invsl,2);
if length(size(regsl))==3,
  nvols=size(regsl,3);
else,
  nvols=1;
end;
disp(sprintf('nvols= %d',nvols));

xx=([1:xdim]-xdim/2)*fov/xdim; xx=xx(:);
xxi=[xx(1):(xx(2)-xx(1))/20:xx(end)]; xxi=xxi(:);

for m=1:nvols,
  cd1(:,:,m)=regsl(:,:,m)+invsl(:,:,m);
  cd2(:,:,m)=regsl(:,:,m)-invsl(:,:,m);
  md1(:,:,m)=abs(regsl(:,:,m))-abs(invsl(:,:,m));
  if (~orthflag),
    yy1(:,m)=abs(squeeze(cd1(loc,:,m)))';
    yy2(:,m)=abs(squeeze(cd2(loc,:,m)))';
    yy3(:,m)=squeeze(md1(loc,:,m))';
  else,
    yy1(:,m)=abs(squeeze(cd1(:,loc,m)))';
    yy2(:,m)=abs(squeeze(cd2(:,loc,m)))';
    yy3(:,m)=squeeze(md1(:,loc,m))';
  end;
  yy1i(:,m)=interp1(xx,yy1(:,m),xxi);  
  yy2i(:,m)=interp1(xx,yy2(:,m),xxi);  
  yy3i(:,m)=interp1(xx,yy3(:,m),xxi);  
end;
if (nvols>1),
  yy1m=mean(yy1i')';
  yy2m=mean(yy2i')';
  yy3m=mean(yy3i')';
else,
  yy1m=yy1i;
  yy2m=yy2i;
  yy3m=yy3i;
end;
yys=[yy1m yy2m yy3m];

iw1_90=find(yy1m>(0.9*max(yy1m)));
iw2_90=find(yy2m>(0.9*max(yy2m)));
iw3_90=find(yy3m>(0.9*max(yy3m)));

iw1_70=find(yy1m>(0.707*max(yy1m)));
iw2_70=find(yy2m>(0.707*max(yy2m)));
iw3_70=find(yy3m>(0.707*max(yy3m)));

iw1_25=find(yy1m>(0.25*max(yy1m)));
iw2_25=find(yy2m>(0.25*max(yy2m)));
iw3_25=find(yy3m>(0.25*max(yy3m)));

iw1_10=find(yy1m>(0.10*max(yy1m)));
iw2_10=find(yy2m>(0.10*max(yy2m)));
iw3_10=find(yy3m>(0.10*max(yy3m)));

w_90(1)=[xxi(iw1_90(end))-xxi(iw1_90(1))];
w_90(2)=[xxi(iw2_90(end))-xxi(iw2_90(1))];
w_90(3)=[xxi(iw3_90(end))-xxi(iw3_90(1))];
w_90(4)=0.9;

w_70(1)=[xxi(iw1_70(end))-xxi(iw1_70(1))];
w_70(2)=[xxi(iw2_70(end))-xxi(iw2_70(1))];
w_70(3)=[xxi(iw3_70(end))-xxi(iw3_70(1))];
w_70(4)=0.707;

w_25(1)=[xxi(iw1_25(end))-xxi(iw1_25(1))];
w_25(2)=[xxi(iw2_25(end))-xxi(iw2_25(1))];
w_25(3)=[xxi(iw3_25(end))-xxi(iw3_25(1))];
w_25(4)=0.25;

w_10(1)=[xxi(iw1_10(end))-xxi(iw1_10(1))];
w_10(2)=[xxi(iw2_10(end))-xxi(iw2_10(1))];
w_10(3)=[xxi(iw3_10(end))-xxi(iw3_10(1))];
w_10(4)=0.1;

prof=[w_90;w_70;w_25;w_10];

if (nargout==0),
  prof,
  subplot(221)
  show(abs(regsl(:,:,1))')
  title('Regular')
  subplot(222)
  show(abs(invsl(:,:,1))')
  title('Inversion')
  subplot(212)
  plot(xxi,yy1m,xxi,yy2m,xxi,yy3m)
  title('Complex subtraction and Magnitude subtraction')
  legend('CD1(+)','CD2(-)','MD1');
  xlabel('Distance')
end;

