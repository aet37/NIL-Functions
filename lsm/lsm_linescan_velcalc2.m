function [lvel]=lsm_lineseries_velcalc2(fname,chname,parms,pivparms)
% Usage ... [lvel]=lsm_lineseries_velcalc2(fname,chname,parms,pivparms)	
%
% parms=[thrf minthr nfo] [1.25 5 16]
% pivparms=[xctype multitype subpixflag] [1 3 0]

if ~exist('chname'), chname='red'; end;

lsmdata=tiffread2c(fname);
eval(sprintf('data=double(lsmdata.%s);',chname));

nlines=size(data,1);
linedim=size(data,2);

linerange=[1 linedim];
nlinesrange=[1 nlines];

bthrf=parms(1);		% 1.25
minthr=parms(2);	% 5
maxthr=max(max(data))-minthr-1;
mfno=3;
nfo=parms(3);		% 16
pparms=[1 3];

dthr1=(linerange(2)-linerange(1)+1)/2;
dthr2=1;
dataii=find((data<maxthr)&(data>minthr));
bthr=mean(data(dataii))+bthrf*std(data(dataii));

for mm=nlinesrange(1):nlinesrange(2)-1,
  % call this default
  tmp1=data(mm,linerange(1):linerange(2));
  tmp2=data(mm+1,linerange(1):linerange(2));
  d0(mm)=simple_piv(tmp1,tmp2,pparms);
  
  % lets try some filtering and recompute
  tmpf1=real(myfilter(medfilt1(tmp1,mfno),nfo));
  tmpf2=real(myfilter(medfilt1(tmp2,mfno),nfo));
  d0f(mm)=simple_piv(tmpf1,tmpf2,pparms);

  % lets binarize and recompute
  tmpb1=double(tmp1>bthr); 
  tmpb2=double(tmp2>bthr);
  if (sum(tmpb1)>0)&(sum(tmpb2)>0)
    d0b(mm)=simple_piv(tmpb1,tmpb2,pparms);
  else
    d0b(mm)=0;
  end;
  tmpb1=double(tmpf1>bthr);
  tmpb2=double(tmpf2>bthr);
  if (sum(tmpb1)>0)&(sum(tmpb2)>0)
    d0fb(mm)=simple_piv(tmpb1,tmpb2,pparms);
  else,
    d0fb(mm)=0;
  end;
end;

dall=[d0(:) d0f(:) d0b(:) d0fb(:)];
if (mean(mean(dall))>dthr1),
  dall=linedim-dall;
end;
for mm=1:size(dall,2),
  tmpii=find((dall(:,mm)>dthr2)&(dall(:,mm)<dthr1));
  tmpii2=find((dall(:,mm)<=dthr2)|(dall(:,mm)>=dthr1));
  drem(mm)=size(dall,1)-length(tmpii);
  davg(mm)=sum(dall(tmpii,mm))/length(tmpii);
  dall(tmpii2,mm)=0;
  clear tmpii tmpii2
end;
drem,
davg,

lvel.filename=fname;
lvel.dd_all=dall;
lvel.dd_avg=davg;
lvel.dd_rem=drem;
lvel.chname=chname;
lvel.nlines=nlines;
lvel.linedim=linedim;

