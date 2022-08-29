function [lvel]=lsm_lineseries_velcalc3(fname,chname,sparms,parms,pparms,wlev,linerange,nlinesrange)
% Usage ... [lvel]=lsm_lineseries_velcalc3(fname,chname,sparms,parms,pparms,wlev,linerange,nlinesrange)
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
  tmp1=data(oo1(mm):oo2(mm),linerange(1));
  tmp2=data(oo1(mm):oo2(mm),linerange(2));

  % change threshold with time for binarizatoin and windowing?
  maxthr(mm)=avgfit(mm)*frat1;
  minthr(mm)=avgfit(mm)*frat2;
  dataii=find((tmp1<=maxthr(mm))&(tmp1>=minthr(mm)));
  bthr(mm)=mean(tmp1(dataii))+bthrf*std(tmp1(dataii));
  tmp1(find(tmp1<=minthr(mm)))=minthr(mm);
  tmp2(find(tmp2>=maxthr(mm)))=maxthr(mm);
  if mfno, tmp1=medfilt1(tmp1,mfno); tmp2=medfilt1(tmp2,mfno); end;

  % call this default
  d0(mm)=simple_piv(tmp1,tmp2,pparms);
  
  % lets try some filtering and recompute
  tmpf1=real(myfilter(tmp1,nfo));
  tmpf2=real(myfilter(tmp2,nfo)); 
  d0f(mm)=simple_piv(tmpf1,tmpf2,pparms);

  % lets binarize and recompute
  tmpb1=double(tmp1>bthr(mm)); 
  tmpb2=double(tmp2>bthr(mm));
  if (sum(tmpb1)>0)&(sum(tmpb2)>0)
    d0b(mm)=simple_piv(tmpb1,tmpb2,pparms);
  else
    d0b(mm)=0;
  end;
  tmpbf1=real(myfilter(tmpb1,nfo));
  tmpbf2=real(myfilter(tmpb2,nfo));
  if (sum(tmpb1)>0)&(sum(tmpb2)>0)
    d0fb(mm)=simple_piv(tmpb1,tmpb2,pparms);
  else,
    d0fb(mm)=0;
  end;
  %keyboard;
end;

dall=[d0(:) d0f(:) d0b(:) d0fb(:)];
%if (mean(mean(dall))>dthr1),
%  dall=linedim-dall;
%end;
%for mm=1:size(dall,2),
%  tmpii=find(abs(dall(:,mm))<dthr1);
%  tmpii2=find(abs(dall(:,mm))>=dthr1);
%  drem(mm)=size(dall,1)-length(tmpii);
%  davg(mm)=sum(dall(tmpii,mm))/length(tmpii);
%  dall(tmpii2,mm)=0;
%  clear tmpii tmpii2
%end;
%drem,
%davg,

lvel.filename=fname;
lvel.dd_all=dall;
%lvel.dd_avg=davg;
%lvel.dd_rem=drem;
lvel.chname=chname;
lvel.nlines=nlines;
lvel.linedim=linedim;
%lvel.bthr=bthr;
%lvel.maxthr=maxthr;
%lvel.minthr=minthr;
lvel.linerange=linerange;
lvel.nlinesrange=nlinesrange;
lvel.ii1=oo1;
lvel.ii2=oo2;
lvel.ii=oo;


