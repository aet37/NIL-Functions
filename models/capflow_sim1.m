%% Capillary flow stdev simulation
%  Start by doing a temporal variance measurement
%  follow that up by a spatial and temporal variance

%close all
clear all

imsz=[256 128];
loc=[128 60];
ww=[260 8];
wwp=[10 8];

im0=rect2d(ww(1),ww(2),loc(1),loc(2),imsz);
im0i=find(im0);

% assume flow in the x-direction
frac=0.35;
navg1=frac*prod(ww)/prod(wwp);
nstd1=0.5*navg1;

dx1=ww(1)/navg1;
dp1=randn(1,round(navg1))*nstd1+dx1;
px1=cumsum(dp1)-dx1;

im1=rect2d(wwp(1),wwp(2),px1,ones(size(px1))*loc(2),imsz);

nfr=300;
xvel=[0 1.1 1.9 3.2 4.4 6.5 9.1 15.7 20.4 31.1 39.6 62.9 94.6 121.2 157.7];

for nn=1:length(xvel),
  navg=frac*((nfr+10)*xvel(nn)+ww(1))*ww(2)/prod(wwp);
  dp=randn(1,ceil(navg))*nstd1+dx1;
  px=cumsum(dp);
  px=px-max(px)+ww(1);

  ims=zeros(size(im0,1),size(im0,2),nfr);
  for mm=1:nfr,
    tmpim1=im0-rect2d(wwp(1),wwp(2),px+(mm-1)*xvel(nn),ones(size(px))*loc(2),imsz);
    ims(:,:,mm)=tmpim1+randn(size(tmpim1))*0.1;
  end;

  %disp(sprintf(' vel= %.1f, nn= %d',xvel(nn),ceil(navg))),
  %figure(1), clf,
  %showMovie(ims)
  %disp(sprintf(' vel= %.1f, nn= %d',xvel(nn),ceil(navg))),
  %pause,
  
  imd=diff(ims,1,3);
  ims_avg=mean(imd,3);
  ims_std=std(imd,[],3);
  ims_cov=ims_std./ims_avg;
  vavg(nn)=mean(ims_avg(im0i));
  vavgs(nn)=std(ims_avg(im0i));
  vstd(nn)=mean(ims_std(im0i));
  vstds(nn)=std(ims_std(im0i));
  vcov(nn)=mean(ims_cov(im0i));
  vcovs(nn)=std(ims_cov(im0i));
  ims_prof_all(:,:,nn)=squeeze(ims(50:70,100,:));
  ims_avg_all(:,:,nn)=ims_avg;
  ims_std_all(:,:,nn)=ims_std;
  ims_cov_all(:,:,nn)=ims_cov;

  clear ims ims_avg ims_std ims_cov
end;

figure(1), clf,
show(im0-im1+0.1*randn(size(im0))),

figure(2), clf,
subplot(321), plot(xvel,[vavg(:)]), axis tight, grid on, fatlines(1.5),
ylabel('Avg'), xlabel('Velocity (pix/frame)'),
subplot(323), plot(xvel,[vstd(:)]), axis tight, grid on, fatlines(1.5),
ylabel('Std'), xlabel('Velocity (pix/frame)'),
subplot(325), plot(xvel,[vcov(:)]), axis tight, grid on, fatlines(1.5),
ylabel('CoV'), xlabel('Velocity (pix/frame)'),
subplot(322), plot(xvel,[vavgs(:)]), axis tight, grid on, fatlines(1.5),
ylabel('Avg-Std'), xlabel('Velocity (pix/frame)'),
subplot(324), plot(xvel,[vstds(:)]), axis tight, grid on, fatlines(1.5),
ylabel('Std-Std'), xlabel('Velocity (pix/frame)'),
subplot(326), plot(xvel,[vcovs(:)]), axis tight, grid on, fatlines(1.5),
ylabel('CoV-Std'), xlabel('Velocity (pix/frame)'),

