function y=fluxAnalysis1(data)
% Usage ... y=fluxAnalysis1(data)

datasz=size(data);
ndim=length(datasz);
avgim=mean(data,ndim);
avgim1=imwlevel(avgim(:,:,1),[0 4000],1).^1;

filt1=im_smooth(avgim1,0.1*datasz(1));
avgim1f=avgim1.*(1+filt1);

avgim1v=1-FarangiFilt2(avgim1f);

avgim1t=im_thr2(avgim1f,'x0.1',[4 4000]);
avgim1d=bwdist(avgim1t>0);


nl=18;
wl=round(0.15*datasz(1));
ww=5;

for mm=1:nl, kk(:,:,mm)=lineIm([wl wl],ww,(mm-1-nl/2)*10); end;

for mm=1:nl, 
    kkims(:,:,mm)=xcorr2(avgim1,kk(:,:,mm)); 
    kkims(:,:,mm)=kkims(:,:,mm)/(sum(avgim1(:))+sum(sum(kk(:,:,mm)))); 
end;
kkim1=sqrt(sum(kkims.^2,3));
kkim1=kkim1/max(kkim1(:));
kkim2=max(kkims,[],3)-min(kkims,[],3);
kkim2=kkim2/max(kkim2(:));

figure(1), clf,
showmany(kk)

figure(2), clf,
showmany(kkims)

figure(3), clf,
subplot(221), show(kkim1),
subplot(222), show(kkim2),
subplot(223), show(kkim1>0.1),
subplot(224), show(kkim2>0.1),


end

%% functions
%

function y=lineIm(dim,wid,angle)
  y=zeros(dim);
  x1=[0:dim(1)-1]-round(dim(1)/2);
  y1=[0:dim(2)-1]-round(dim(2)/2);
  %xi=find(abs(x1)<100*eps);
  %y1=y(xi+[0:wid-1]-round(wid/2),:)=1;
  [xx,yy]=meshgrid(x1,y1');
  y1=1./(1+exp((abs(ii)-co(mm))/wid(mm)));
  
  %y=rot2d_f(y,angle);
  %y=double(y>0.5);
end
