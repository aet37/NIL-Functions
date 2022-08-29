
%
% Vessel diameter simulation and clean up by PCA
%

clear all
close all

if 1,
    
datasz=[160 160 400];
tt=[1:datasz(3)]/5;
ww=0.1*(1+0.8*gammafun2(tt,8.1,4.5,2));

ang=-51*(pi/180);
rotm=[cos(ang) -sin(ang);sin(ang) cos(ang)];

[xx,yy]=meshgrid([0:datasz(1)-1]'/datasz(1)-0.5,[0:datasz(2)-1]/datasz(2)-0.5);
rax1=1; 
rax2=rax1*sec(pi*44/180);

data=zeros(datasz);
for mm=1:length(ww);
  tmprr=[yy(:) xx(:)]*rotm;
  tmpxx=reshape(tmprr(:,1),datasz(1:2));
  tmpyy=reshape(tmprr(:,2),datasz(1:2));
  tmpii = sqrt( (rax1*tmpxx).^2 + (rax2*tmpyy).^2 );
  tmpim = 1./(1 + exp((tmpii-ww(mm))/0.01) );
  %tmpnn = 0.1*randn(datasz(1:2));
  %tmpnn = abs(0.1*randn(datasz(1:2)));
  tmpnn = 0.2*abs(randn(datasz(1:2)).*exp(j*randn(datasz(1:2))));
  data(:,:,mm) = tmpim + tmpnn;
end;

figure(1), clf,
subplot(211), plot(tt,ww), axis tight, grid on, fatlines(1);
subplot(223), plot(squeeze(data(datasz(1)/2,:,:))'), axis tight, grid on,
subplot(224), plot(squeeze(data(:,datasz(2)/2,:)) ), axis tight, grid on,

figure(2), clf,
showMovie(data)

end

%
% Try PCA-based filtering
%


if 0,
%tmpstk=pcaimdenoise(data,40,1,1);
%mypca=mypcadecomp(data,40);

tmpstk=pcaimdenoise(data,'select',1,1);


%
% Measure vessels in both normal and filtered data sets and compare
%

load vessel_sim2_rad1

rr1=calcRadius6(data,rad1,1);
rr1f=calcRadius6(tmpstk,rad1,1);
rr1n=rr1./(ones(size(rr1,1),1)*mean(rr1(1:36,:),1));
rr1fn=rr1f./(ones(size(rr1,1),1)*mean(rr1f(1:36,:),1));

figure(3)
subplot(221), plot(tt,rr1), axis tight, grid on,
subplot(222), plot(tt,rr1f), axis tight, grid on,
subplot(223), plot(tt,rr1n), axis tight, grid on,
subplot(224), plot(tt,rr1fn), axis tight, grid on,

end

