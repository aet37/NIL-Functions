function [info,data_all]=my_plx_read(filename,chid,trigid,durarray)
% Usage ... [info,data]=my_plx_read(filename,chid,trigid,durarray)
% 
% Ex. plx_ch1=my_plx_read('LOT_COMP.plx',0);
%     plx_ch11=my_plx_read('LOT_COMP.plx',10);


if length(filename)==0,
  [fname,pname]=uigetfile('*.plx','Select a PLX file');
  filename=strcat(pname,fname);
end;

if ~exist('chid','var'), chid=[]; end;
if ~exist('trigid','var'), trigid=[]; end;
if ~exist('durarray','var'), durarray=[]; end;

if isempty(chid), chid=0; end;
if isempty(trigid), trigid=3; end;
if isempty(durarray), durarray=[-1000 11000]; end;

trig_ts=[];

fid=fopen(filename,'r','l');
if (fid<3),
  error(sprintf('Could not open file %s',filename));
end;

disp(sprintf('  File= %s',filename));

% Read Plexon header
disp(sprintf('  Reading header...'));
plxheader=fread(fid,64,'int32');
freq=plxheader(35);
ndsp=plxheader(36);
nevents=plxheader(37);
nslow=plxheader(38);
npw=plxheader(39);
npr=plxheader(40);
tscounts=fread(fid,[5 130],'int32');
wfcounts=fread(fid,[5 130],'int32');
evcounts=fread(fid,[1 512],'int32');

% skip DSP and Event headers
fseek(fid,1020*ndsp+296*nevents,'cof');

% read one A/D header and get the frequency
adheader = fread(fid,74,'int32');
adfreq = adheader(10);

% skip all other a/d headers
%fseek(fid,1020*ndsp+296*nevents+296*nslow,'cof');
fseek(fid, 296*(nslow-1), 'cof');

disp(sprintf('  AD Freq= %.1f (%.1f, eventCh# %d)',adfreq,freq,trigid));

i1=ftell(fid);
fseek(fid,0,'eof');
i2=ftell(fid);
fseek(fid,i1,'bof');

% Read preliminary time-stamps
n=0; nnn=0;
records=0;
tmp_ok=1;
floc1=ftell(fid);
tmp_fix0=0;
while feof(fid)==0,
  records=records+1;
  floc=ftell(fid);
  type=fread(fid,1,'int16');
  upperbyte=fread(fid,1,'int16');
  timestamp=fread(fid,1,'int32');
  channel=fread(fid,1,'int16');
  unit=fread(fid,1,'int16');
  nwf=fread(fid,1,'int16');
  nwords=fread(fid,1,'int16');
  if nwords>0,
    wf=fread(fid,nwords,'int16');
  else,
    wf=[];
  end;
  if type==4,
    if channel==trigid,
      nnn=nnn+1;
      trig_ts(nnn)=timestamp;
    end;
  end;


  data_all(records).timestamp=single(timestamp);
  data_all(records).channel=int16(channel);
  data_all(records).type=int16(type);
  data_all(records).unit=int16(unit);
  data_all(records).ndata=single(nwf);
  data_all(records).data=single(wf);

  %tloc(records)=int32(floc);
  %tt(records)=int32(timestamp);
  %keyboard,

  tmp_prog=100*(floc-floc1)/(i2-i1);
  tmp_fix=fix(tmp_prog/5);
  if tmp_fix~=tmp_fix0,
    disp(sprintf('  Progress= %.1f%% (%d,%d)',tmp_prog,floc,i2));
    tmp_fix0=tmp_fix;
  end;
end;

disp(sprintf('  #events on %d= %d',trigid,nnn));

info.freq=freq;
info.adfreq=adfreq;
info.nevents=nevents;
info.nslow=nslow;
info.nrecords=records;
info.timestamp_all=[data_all(:).timestamp];
info.channel_all=[data_all(:).channel];
info.type_all=[data_all(:).type];
info.unit_all=[data_all(:).unit];
info.ndata_all=[data_all(:).ndata];

% parse data by type and channel
utypes=unique(info.type_all);
uchannels=unique(info.channel_all);
min_type=min(info.type_all);
max_type=max(info.type_all);
min_channel=min(info.channel_all);
max_channel=max(info.channel_all);
disp(sprintf('  min/max type = [%d %d]',min_type,max_type));
disp(sprintf('  min/max channel = [%d %d]',min_channel,max_channel));

if isempty(chid),  
  % original parsing
  for mm=min_channel:max_channel,
    tmp_channel=find(info.channel_all==mm);
    if ~isempty(tmp_channel),
      disp(sprintf('  channel# %d',mm));
      for nn=1:min_type:max_type,
        tmp_type=find(info.type_all(tmp_channel)==nn);
        if (~isempty(tmp_type)),
          disp(sprintf('    type# %d',nn));
          eval(sprintf('info.channel%d_type%d=[]; info.channel%d_type%d_ts=[];',mm,nn,mm,nn));
          for oo=1:length(tmp_type),
            eval(sprintf('tmpii=length(info.channel%d_type%d)+[1:length(data_all(tmp_type(oo)).data(:))];',mm,nn));
            eval(sprintf('info.channel%d_type%d(tmpii)=single(data_all(tmp_type(oo)).data(:))'';',mm,nn));
            %if (data_all(tmp_type(oo)).ndata>0),
            %  eval(sprintf('info.channel%d_type%d_ts=[info.channel%d_type%d_ts data_all(tmp_type(oo)).timestamp*ones(1,data_all(tmp_type(oo)).ndata)];',mm,nn,mm,nn));
            %else,
            %  eval(sprintf('info.channel%d_type%d_ts=[info.channel%d_type%d_ts data_all(tmp_type(oo)).timestamp];',mm,nn,mm,nn));
            %end;
            if (length(data_all(tmp_type(oo)).data)>0),
              eval(sprintf('info.channel%d_type%d_ts(tmpii)=single(data_all(tmp_type(oo)).timestamp*ones(1,length(data_all(tmp_type(oo)).data)));',mm,nn));
            else,
              eval(sprintf('info.channel%d_type%d_ts(tmpii)=single(data_all(tmp_type(oo)).timestamp);',mm,nn,mm,nn));
            end;
          end;
        end;
      end;
    end;
  end;
else,
  % new channel parsing
  yy=[]; tt=[];
  tmpii=find(info.channel_all==chid);
  tmpi5=find(info.type_all==5);
  if ~isempty(tmpii),
    for mm=1:length(tmpii), 
      if data_all(tmpii(mm)).type==5,
        tmpdata=data_all(tmpii(mm)).data(:);
        tmptt=[0:length(tmpdata)-1]+data_all(tmpii(mm)).timestamp;
        tmpai=length(yy)+[1:length(tmpdata)];
        yy(tmpai)=tmpdata(:);
        tt(tmpai)=tmptt(:);
      end;
    end;
  end;
  
  ttnew=[min(tt):max(tt)]; %[min(tt),max(tt)],
  [utt,uii]=unique(tt);
  yynew=interp1(single(tt(uii)),single(yy(uii)),single(ttnew));
  
  clear info
  info.freq=freq;
  info.adfreq=adfreq;
  info.trigid=trigid;
  info.trign=nnn;
  info.trigts=single(trig_ts)/freq;
  info.chid=chid;
  info.type=5;
  info.tt=single(tt)/freq;
  info.yy=single(yy);
  if ~isempty(tmpii),
    info.tt_orig=info.tt;
    info.yy_orig=info.yy;
    info.tt=single(ttnew)/freq;
    info.yy=single(yynew);
  end;
  %if nnn>=1,
  %  info.ntt=[durarray(1)/1000:1/adfreq:durarray(2)/1000]';
  %  for oo=1:nnn,
  %    info.ndata(:,oo)=interp1(info.tt(:)-info.trigts(oo),info.yy(:),info.ntt(:));
  %  end;
  %end;
end;

fixtime_flag=0;
if (fixtime_flag),
  tmptt=[durarray(1)/1000:1/adfreq:durarray(2)/1000];
  for mm=1:n,
    eval(sprintf('tmin(mm)=min(rts%02d);',mm));
    eval(sprintf('tmax(mm)=max(rts%02d);',mm));
  end;
  tmpt1=find(tmptt>=max(tmin));
  tmpt2=find(tmptt>=min(tmax));
  if isempty(tmpt1), tmpt1=1; end;
  if isempty(tmpt2), tmpt2=length(tmptt); end;
  ntt=tmptt(tmpt1(1):tmpt2(1));
  for mm=1:n,
    eval(sprintf('ndata(:,mm)=interp1(rts%02d(:),data%02d(:),ntt(:));',mm,mm));
  end;
  data.ntt=ntt;
  data.ndata=ndata;
end;

