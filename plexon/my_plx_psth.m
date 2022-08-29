function [data]=my_plx_psth(filename,trig_id,data_ch,dur_array,tbin,nunit)
% Usage ... [data]=my_plx_psth(filename,trig_id,data_ch,dur_array,tbin,unit)

if ~exist('nunit'),
  nunit_flag=0;
else,
  nunit_flag=1;
end;

if length(filename)==0,
  [fname,pname]=uigetfile('*.plx','Select a PLX file');
  filename=strcat(pname,fname);
end;

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
disp(sprintf('  Reading records, searching id %d ...',trig_id));
n=0;
o=0;
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
  if type==4,
    if channel==trig_id,
      n=n+1;
      tt(n)=timestamp;
      sv(n)=unit;
      nw(n)=nwords;
      chid(n)=channel;
      recno(n)=records;
    end;
  end;
  if type==1,
    if channel==data_ch,
      o=o+1;
      data_ts(o)=timestamp;
      data_u(o)=unit;
    end;
  end;
  %tloc(records)=int32(floc);
  %tt(records)=int32(timestamp);

  tmp_prog=100*(floc-floc1)/(i2-i1);
  tmp_fix=fix(tmp_prog/5);
  if tmp_fix~=tmp_fix0,
    disp(sprintf('  Progress= %.1f%% (%d,%d)',tmp_prog,floc,i2));
    tmp_fix0=tmp_fix;
  end;
end;

disp(sprintf('  #Events/#Spikes= %d/%d (%d)',n,o,records));

data.freq=freq;
data.adfreq=adfreq;
data.nevents=nevents;
data.nslow=nslow;
data.nrecords=records;

data.n=n;
data.o=o;
data.tt=tt;
data.nw=nw;
data.recno=recno;
data.trigid=trig_id;
data.datach=data_ch;
data.durarray=dur_array;
data.tbin=tbin;
if nunit_flag, data.unit=nunit; end;

nbins=ceil((dur_array(2)-dur_array(1))/tbin);
bdata=zeros(n,nbins);
for mm=1:n,
  tmpbins=zeros(nbins,1);
  tmp1=find((data_ts-tt(n)+dur_array(1))&(data_ts-tt(n)+dur_array(2)));
  if ~isempty(tmp1),
    tmp2=ceil((data_ts(tmp1)-tt(n)+dur_array(1))/tbin);
    for nn=1:length(tmp2),
      tmpbins(tmp2(nn))=tmpbins(tmp2(nn))+1;
    end;
  end;
  bdata(:,mm)=tmpbins;
end;

data.btime=[dur_array(1):tbin:dur_array(2)];
data.bdata=bdata;

_ts(tmp1)-tt(mm)-dur_array(1))/tbin);
    for nn=1:length(tmp2),
      tmpbins(tmp2(nn))=tmpbins(tmp2(nn))+1;
    end;
  end;
  bdata(:,mm)=tmpbins;
end;

data.data_ts=data_ts;
data.data_unit=data_u;

data.btime=[dur_array(1)+tbin/2:tbin:dur_array(2)];
data.bdata=bdata;
data.bspikes=bdata/tbin;

