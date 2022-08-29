function [lvel]=lsm_lineseries_velcalc4(fname,chname,sparms,parms,pparms,wlev,linerange,nlinesrange)
% Usage ... [lvel]=lsm_lineseries_velcalc4(fname,chname,sparms,parms,pparms,wlev,linerange,nlinesrange)
%
% parms=[thrf minthr nfo] [1.25 5 16]
% pivparms=[xctype multitype subpixflag] [1 3 0]

if ~exist('chname'), chname='red'; end;
if ~exist('pparms'), pparms=[1 3]; end;

if isstr(fname),
  lsmdata=tiffread2c(fname);
  eval(sprintf('data=double(lsmdata.%s);',chname));
else,
  lsmdata=fname;
  eval(sprintf('data=double(lsmdata.%s);',chname));
end; 

wlines=sparms(1);
if length(sparms>1), olines=sparms(2); else, olines=0; end;

nlines=size(data,1);
linedim=size(data,2);


if ~exist('linerange'), linerange=[]; end;
if ~exist('nlinesrange'), nlinesrange=[]; end;

if isempty(nlinesrange), nlinesrange=[1 nlines]; end;
if isempty(linerange), linerange=[1 linedim]; end;

avgdata=mean(data');
avgfit=exp1decayfit(avgdata);

bthrf=parms(1);		% 1.25
nfo=parms(2);		% 16
mfno=parms(3);		% 0

if length(parms)<4, tmpang0=0; else, tmpang0=parms(4); end;

% fix the thresholds
if ~exist('wlev'), wlev=[]; end;
if isempty(wlev),
  maxthr=max(max(data))*0.97;
  minthr=min(min(data));
  if minthr==0, minthr=0.03*max(max(data)); end;
else,
  minthr=wlev(1);
  maxthr=wlev(2);
end;
disp(sprintf('  bthrf= %f  nfo= %d  mfn= %d',bthrf,nfo,mfno));
disp(sprintf('  initial wlev= [%f  %f]',minthr,maxthr));
disp(sprintf('  line range= [%d  %d]',linerange(1),linerange(2)));
disp(sprintf('  #lines range= [%d  %d]',nlinesrange(1),nlinesrange(2)));
disp(sprintf('  #lines wind= %d   #lines wind overlap= %d',wlines,olines));

frat1=maxthr/avgfit(1);
frat2=minthr/avgfit(1);

dthr1=(linerange(2)-linerange(1)+1)/2;
dthr2=1;

tmpoo1=[nlinesrange(1):wlines-olines:nlinesrange(2)];
tmpoo2=[nlinesrange(1)+wlines-1:wlines-olines:nlinesrange(2)+wlines-1];
tmpooi=find(tmpoo2<=nlinesrange(2));
oo1=tmpoo1(tmpooi);
oo2=tmpoo2(tmpooi);
oo=(oo1+oo2)/2;
clear tmpoo1 tmpoo2 tmpooi

for mm=1:length(oo2),
  % first, load data
  tmp1=data(oo1(mm):oo2(mm),linerange(1):linerange(2));

  % change threshold with time for binarizatoin and windowing?
  maxthr(mm)=avgfit(oo1(mm))*frat1;
  minthr(mm)=avgfit(oo1(mm))*frat2;
  dataii=find((tmp1<=maxthr(mm))&(tmp1>=minthr(mm)));
  bthr(mm)=mean(tmp1(dataii))+bthrf*std(tmp1(dataii));
  tmp1(find(tmp1<=minthr(mm)))=minthr(mm);
  tmp1(find(tmp1>=maxthr(mm)))=maxthr(mm);
  if mfno, tmp1=medfilt1(tmp1,mfno); tmp1=medfilt2(tmp1,[mfno mfno]); end;

  % operate in the frequency domain and find rotated angle
  tmp1=tmp1-mean(mean(tmp1));
  tmp1f=abs(fft2(tmp1));
  tmp1s=sum(tmp1f);
  tmpang=fminbnd(@(xx) imrotsum(xx,tmp1),tmpang0-30,tmpang0+30);
  tmp1r=imrotate(tmp1,tmpang,'bilinear','crop');
  tmp1fr=abs(fft2(tmp1r));
  tmp1sr=sum(tmp1fr);
  [tmp1fr_max,tmp1fr_maxi]=max(tmp1fr');
  
  % calculate displacement
  rotang(mm)=tmpang;
  dd(mm)=(linerange(2)-linerange(1)+1)*sin(tmpang*pi/180);	% 1/sin(rad_ang)
  rotmin1(mm,:)=[tmp1sr(1) tmp1s(1)];
  if abs(tmpang0-tmpang)<30, tmpang0=tmpang; end;
  %keyboard;

end;


lvel.filename=fname;
lvel.dd=dd;
lvel.rotang=rotang;
lvel.rotmin1=rotmin1;
lvel.chname=chname;
lvel.nlines=nlines;
lvel.linedim=linedim;
lvel.bthr=bthr;
lvel.maxthr=maxthr;
lvel.minthr=minthr;
lvel.linerange=linerange;
lvel.nlinesrange=nlinesrange;
lvel.ii1=oo1;
lvel.ii2=oo2;
lvel.ii=(oo1+oo2)/2;

tmp_ddavg=mean(dd);
tmp_ddstd=std(dd);
tmp_ddii=find(abs(dd)<5e-4);
if ~isempty(tmp_ddii),
  dd_orig=dd;
  ddlen=length(dd);
  disp(sprintf('  #outliers= %d',length(tmp_ddii)));
  for mm=1:length(tmp_ddii),
    if ((tmp_ddii(mm)~=1)|(tmp_ddii(mm)~=ddlen)),
      dd(tmp_ddii(mm))=0.5*(dd_orig(tmp_ddii(mm)-1)+dd_orig(tmp_ddii(mm)+1));
    end;
  end;
  lvel.dd_orig=dd_orig;
  lvel.dd=dd;
end;



function ymin=imrotsum(ang0,im)
% Usage ... ymin=imrotsum(ang0,im)

if nargin<3, range=[1 size(im,1) 1 size(im,2)]; end;

rotim=imrotate(im,ang0,'bilinear','crop');
imfm=abs(fft2(rotim));
ysum=sum(imfm);
ymin=1/ysum(1);

return;

