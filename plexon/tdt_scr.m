
clear all
close all

trdur=40;
troff=5;

% map of site position from top-to-bottom
i2d=[9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6];

% tdt file name already converted to matlab
fname='Rat20130207_Block-002.mat';
do_cars=1;
do_average=1;

% load data
eval(sprintf('load %s',fname));
tdtfs=data.STRM.samprate;
datatime=data.STRM.time;
carstime=data.CARS.time;
carsdata=double(data.CARS.data{1});
il=length(data.STRM.data{1});
if length(carsdata)>il,
  carsdata=carsdata(1:il); 
elseif length(carsdata)<il,
  il=length(carsdata);
end;
strmdata=zeros(il,length(i2d));
for mm=1:length(i2d),
  tmp=double(data.STRM.data{i2d(mm)}(1:il));
  if do_cars,
    strmdata(:,mm)=tmp(:)-carsdata(:);
  else,
    strmdata(:,mm)=tmp(:);
  end;
end;
clear tmp*

% recreate triggers
tt=[0:size(strmdata,1)-1]'/tdtfs;
trigtime=data.Trig.time;
trigdata=zeros(size(tt));
for mm=1:length(trigtime)/2,
  trigdata(find((tt>=trigtime(2*mm-1))&(tt<trigtime(2*mm))))=1;
end;
tmpii=find(trigdata>0.5);
tmpi2=find(diff(tmpii)>10*tdtfs);
trigi0=[tmpii(1);tmpii(tmpi2+1)];

% average if desired
ntr=length(trigi0);
ttt=[0:1/tdtfs:trdur]-troff;
strmdata_tr=zeros(length(ttt),size(strmdata,2),ntr);
for mm=1:size(strmdata,2), for nn=1:ntr,
  strmdata_tr(:,mm,nn)=interp1(tt,strmdata(:,mm),ttt+tt(trigi0(nn)));
end; end;
clear tmp*

% compute CSD
tmpcsd=mycsd(mean(strmdata_tr,3),ttt,[1:16]*100,[1e-4 100 20]);
figure(1),
plotcsd2(tmpcsd,[-1 1]*1e-8,[],[-0.1 0.4])
xlabel('Time (s)')
ylabel('Depth (um)')
figure(2),
plotcsd2(tmpcsd,[-1 1]*1e-8,5000,[-0.1 0.4])
xlabel('Time (s)')
ylabel('Depth (um)')

% calculate MUA
muaf=3.5;
muabin=0.050;
muathr=[-1 1]*mean(mean(squeeze(std(strmdata_tr,[],1))))*muaf+mean(strmdata_tr(:));
for mm=1:length(i2d), for nn=1:ntr,
  [strmmua(:,mm,nn),tmua]=calcMUA(strmdata_tr(:,mm,nn),ttt,muathr,muabin);
end; end;

figure(3)
pcolor(tmua,-[1:16]*100,mean(strmmua,3)')
shading interp, axis tight,
set(gca,'XLim',[-2 8])
set(gca,'CLim',[0 3])
xlabel('Time (s)')
ylabel('Depth (um)')

figure(4)
plotmany(tmua,mean(strmmua,3),[],[-3 9])
xlabel('Time (s)')
ylabel('Depth (um)')

figure(5)
im1=find((tmua>-0.1)&(tmua<0.1));
plot([1:16]*100,mean(max(strmmua(im1,:,:),[],1),3))
xlabel('Depth (um)'),
ylabel('Max MUA (spk/sec)')
axis('tight'), grid('on'),
tmpax=axis; axis([tmpax(1:2) 0 tmpax(4)]),

