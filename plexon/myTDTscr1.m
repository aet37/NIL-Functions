function y=myTDTscr1(TDTmat,TDTid,



eval(sprintf('load %s',TDTmat)); 

% get essential data from TDT data structure
if isfield(data,'streams'),
  fs=data.streams.STRM.fs;
  nch=size(data.streams.STRM.data,1);
  tt=[0:length(data.streams.STRM.data(1,:))-1]/fs;

  % get the start-of-frame trigger
  if isfield(data.epocs,'Trig'), flags.do_trig=1; else, flags.do_trig=0; end;
  if do_trig,
    trigON_ii=find(data.epocs.Trig.data>0);
    trigON_time=data.epocs.Trig.onset(trigON_ii);
    for mm=1:length(trigON_time), trigON_ii(mm)=find(tt>=trigON_time(mm),1); end;
  end;
  
  % copy data
  strm=single(zeros(size(data.streams.STRM.data')));
  for mm=1:nch, strm(:,mm)=single(data.streams.STRM.data(mm,:)); end;
  for mm=1:nch, strm(:,mm)=strm(:,mm)-mean(strm(1:round(2*fs),mm)); end;

else,
  fs=data.STRM.samprate;
  nch=length(data.STRM.data);
  tt=[0:length(data.STRM.data{1})-1]/fs;
  
  % get the start-of-frame trigger
  if isfield(data,'Trig'), flags.do_trig=1; else, flags.do_trig=0; end;
  trigON_ii=find(data.Trig.data{1}>0.1);
  trigON_time=data.Trig.time(trigON_ii);
  for mm=1:length(trigON_time), trigON_ii(mm)=find(tt>=trigON_time(mm),1); end;

  % copy data
  strm=single(zeros(length(data.STRM.data{1}),length(data.STRM.data)));
  for mm=1:nch, strm(:,mm)=single(data.STRM.data{mm}); end;
  for mm=1:nch, strm(:,mm)=strm(:,mm)-mean(strm(1:round(2*fs),mm)); end;

end;
clear data


if flags.do_remap,
  strm=strm(:,sitemap);
  flags.do_remap_done=1;
end;


if do_setfilterspk,
  spkfilter=flags.setfilterspk_parms;
else,
  spkfilter=[300 9000];
end;

if do_setfilterlfp,
  lfpfilter=flags.setfilterlfp_parms;
else,
  lfpfilter=[1 150];
end;


if do_filterfirst,
  for mm=1:nch, strm(:,mm)=single(fermi1d(double(strm(:,mm)),[300 9000],[10 30],[-1 1],1/fs)); end;
  if do_lfp,
    strmlfp=single(zeros(size(strm)));
    for mm=1:nch, strmlfp(:,mm)=single(fermi1d(double(strm(:,mm)),[1 150],[0.2 10],[-1 1],1/fs)); end;
    %strmlfp=ybin2(strmlfp,lfpdn);
    %ttlfp=ybin2(tt,lfpdn);
  end;
end;

