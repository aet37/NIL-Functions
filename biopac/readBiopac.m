function [f1,f2,f3,f4,f5,f6,f7,f8,f9,f10]=readBiopac(fname,trigCh,trigSelect,trigSamples,outCh)
% Usage ... f=readBiopac(fname,trigCh,trigSelect,trigSamples,outCh)


verbose_flag=1;

if nargin<2,
  trigCh=12;
end;
if nargin<3,
  trigSelect=[];
end;

if isempty(trigSelect),
  trigSelect_flag=0;
else,
  trigSelect_flag=1;
end;

if trigSelect_flag,
  if length(trigSamples)==1,
    trigSamples=ones(size(trigSelect))*trigSamples(1);
  end;
end;

%f.ch.aux1=1;
%f.ch.aux2=2;
%f.ch.aux3=3;
%f.ch.tb=4;
%f.ch.flux=5;
%f.ch.po2a=6;
%f.ch.po2b=7;

%f.ch.bp=6;
%f.ch.ecg=7;
%f.ch.iso=8;
%f.ch.co2=9;
%f.ch.co2b=10;
%f.ch.trig=11;
%f.ch.stim=12;
%f.ch.rr=14;
%f.ch.hr=15;

%
% Typical channel arrangement:
%  1: AUX1
%  2: AUX2
%  3: AUX3
%  4: TB
%  5: FLUX
%  6: PO2A
%  7: PO2B
%  8: SIGH
%  9: ICP
% 10: MABP
% 11: ECG
% 12: EEG
% 13: ISO
% 14: O2
% 15: N2O
% 16: CO2
%

if strcmp(fname(end-2:end),'txt')|strcmp(fname(end-2:end),'TXT'),
  text_flag=1;
  disp('Reading data...');
  eval(sprintf('load %s',fname));
  eval(sprintf('biopac_data=%s; clear %s ',fname(1:end-4),fname(1:end-4)));
else,
  text_flag=0;
  error('Non-Text Biopac files are not yet supported!')
end;

if nargin<5,
  outCh=[1:size(biopac_data,2)];
end;

disp('Parsing Trigger Channel...');
ii_trig=find(biopac_data(:,trigCh)>1);
if (isempty(ii_trig)),
  error(sprintf('No triggers found in channel %d !!!',trigCh));
end;

iid_trig=diff(ii_trig);
iid_i=find(iid_trig>1);
ii2_trig(1)=ii_trig(1);
ii2_trig(2:length(iid_i)+1)=ii_trig(iid_i+1);
ii2d_trig=diff(ii2_trig);

if (verbose_flag),
  disp('Trigger locations found:');
  ii2_trig(:),
  disp('Distance between triggers:');
  ii2d_trig(:),
end;

if (trigSelect_flag),
  for mm=1:length(trigSelect),
    %ii2_trig(trigSelect(mm)),
    eval(sprintf('f%1d=biopac_data(ii2_trig(trigSelect(mm)):ii2_trig(trigSelect(mm))+trigSamples-1,outCh);',mm));
  end;
else,
  for mm=1:length(ii2_trig)-1,
    %[ii2_trig(mm) ii2_trig(mm+1)-1],
    eval(sprintf('f%1d=biopac_data(ii2_trig(mm):ii2_trig(mm+1)-1,outCh);',mm));
  end;
end;

keyboard,

