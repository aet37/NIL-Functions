function [data]=my_plx_lfp(filename,trig_ch,trig_no,lfp_ch,dur_array)
% Usage ... [data]=my_plx_lfp(filename,trig_ch,trig_no,lfp_ch,dur_array)
%
% trig_ch is of type 5 data (not event type 4)
% trig_no is the vector of triggers that are needed (refer to my_plx_tstamp)

if length(filename)==0,
  [fname,pname]=uigetfile('*.plx','Select a PLX file');
  filename=strcat(pname,fname);
end;

if ~exist('trig_ch'), trig_ch=[]; end;
if ~exist('trig_no'), trig_no=[]; end;
if ~exist('lfp_ch'), lfp_ch=[]; end;
if ~exist('dur_array'), dur_array=[]; end;

if isempty(trig_ch), trig_ch=11; else, do_readall=0; end;
if isempty(trig_no), do_readall=1; else, do_readall=0; end;
if isempty(lfp_ch), lfp_ch=0; end;
if isempty(dur_array), dur_array=[0 1000e3]; end;

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

disp(sprintf('  AD Freq= %.1f (%.1f)',adfreq,freq));

i1=ftell(fid);
fseek(fid,0,'eof');
i2=ftell(fid);
fseek(fid,i1,'bof');

% Read preliminary time-stamps
disp(sprintf('  Reading records, searching id %d (5) ...',trig_ch));
n=0;
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
  end;
  if type==5,
    if channel==trig_ch,
      n=n+1;
      tt(n)=timestamp;
      sv(n)=unit;
      nw(n)=nwords;
      chid(n)=channel;
      recno(n)=records;
      if do_readall==1, break; end;
    end;
  end;
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

disp(sprintf('  #Events= %d (%d)',n,records));

% Read data
disp(sprintf('  Reading data, searching id %d ...',lfp_ch));
fseek(fid,floc1,'bof');
records2=0;
n2=zeros(1,length(trig_no));
nw2=n2;
tt1=n2;
tt2=n2;
recno1=n2;
recno2=n2;
tmp_fix0=0;
for mm=1:length(trig_no),
  eval(sprintf('data%02d=[];',mm));
end;
while feof(fid)==0,
  records2=records2+1;
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
    if (type==5)&(channel==lfp_ch),
      tmp1=find(((timestamp-tt(n(trig_no)))>=(dur_array(1)*freq/1000))&((timestamp-tt(n(trig_no)))<(dur_array(2)*freq/1000)));
      if ~isempty(tmp1),
        for mm=1:length(tmp1),
	  n2(tmp1(mm))=n2(tmp1(mm))+1;  
          eval(sprintf('data%02d(nw2(tmp1(mm))+1:nw2(tmp1(mm))+nwords)=wf;',tmp1(mm)));
          eval(sprintf('rts%02d(nw2(tmp1(mm))+1:nw2(tmp1(mm))+nwords)=[0:nwords-1]/adfreq+(timestamp-tt(tmp1(mm)))/freq;',tmp1(mm)));
          nw2(tmp1(mm))=nw2(tmp1(mm))+nwords;
          if tt1(tmp1(mm))==0, 
	    tt1(tmp1(mm))=timestamp;
            recno1(tmp1(mm))=records2;
	  else,
	    tt2(tmp1(mm))=timestamp;
            recno2(tmp1(mm))=records2;
	  end;
	end;
      end;
    end;
  end;

  tmp_prog=100*(floc-floc1)/(i2-i1);
  tmp_fix=fix(tmp_prog/5);
  if tmp_fix~=tmp_fix0,
    disp(sprintf('  Progress= %.1f%% (%d,%d)',tmp_prog,floc,i2));
    tmp_fix0=tmp_fix;
  end;
end;


data.freq=freq;
data.adfreq=adfreq;
data.nevents=nevents;
data.nslow=nslow;
data.nrecords=records;

data.n=n;
data.tt=tt;
data.sv=sv;
data.nw=nw;
data.recno=recno;
data.trigch=trig_ch;
data.trigno=trig_no;

data.nd=n2;
data.ndw=nw2;
data.tt1=tt1;
data.tt2=tt2;
data.recno1=recno1;
data.recno2=recno2;
data.lfpch=lfp_ch;
data.durarray=dur_array;
for mm=1:length(trig_no),
  eval(sprintf('data.data%02d=data%02d;',mm,mm));
  eval(sprintf('data.rts%02d=rts%02d;',mm,mm));
end;

fixtime_flag=1;
if (fixtime_flag),
  tmptt=[dur_array(1)/1000:1/adfreq:dur_array(2)/1000];
  for mm=1:length(trig_no),
    eval(sprintf('tmin(mm)=min(rts%02d);',mm));
    eval(sprintf('tmax(mm)=max(rts%02d);',mm));
  end;
  tmpt1=find(tmptt>=max(tmin));
  tmpt2=find(tmptt>=min(tmax));
  if isempty(tmpt1), tmpt1=1; end;
  if isempty(tmpt2), tmpt2=length(tmptt); end;
  ntt=tmptt(tmpt1(1):tmpt2(1));
  for mm=1:length(trig_no),
    eval(sprintf('ndata(:,mm)=interp1(rts%02d(:),data%02d(:),ntt(:));',mm,mm));
  end;
  data.ntt=ntt;
  data.ndata=ndata;
end;

