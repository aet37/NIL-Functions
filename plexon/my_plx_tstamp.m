function [data]=my_plx_tstamp(filename,dchId,trigId)
% Usage ... [data]=my_plx_tstamp(filename,chId,trigId)

if length(filename)==0,
  [fname,pname]=uigetfile('*.plx','Select a PLX file');
  filename=strcat(pname,fname);
end;

if ~exist('dchId'), dchId=[]; end;
if ~exist('trigId'), trigId=[]; end;

if isempty(dchId), dchId=11; do_readall=1; else, do_readall=0; end;
if isempty(trigId), do_trig=0; else, do_trig=1; end;

if length(dchId)>1, do_multich=1; nch=length(dchId); else, do_multich=0; end;

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
disp(sprintf('  Reading records, searching id %d ...',dchId(1)));
n=0;
records=0;
n_trg=0;
tmp_ok=1;
floc1=ftell(fid);
tmp_fix0=0;
if do_multich, for mm=2:nch, eval(sprintf('n%d=0;',mm)); end; end;
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
  if do_trig,
  if type==4,
    if channel==trigId,
      n_trg=n_trg+1;
      tt_trg(n_trg)=timestamp;
      sv_trg(n_trg)=unit;
      nw_trg(n_trg)=nwords;
      chid_trg(n_trg)=channel;
      recno_trg(n_trg)=records;
    end;
  end;
  end;
  if type==5,
    if channel==dchId(1),
      n=n+1;
      tt(n)=timestamp;
      sv(n)=unit;
      nw(n)=nwords;
      chid(n)=channel;
      recno(n)=records;
    end;
    if do_multich,
      for mm=2:nch,
        if channel==dchId(mm),
          eval(sprintf('n%d=n%d+1;',mm,mm));
          eval(sprintf('tt%d(n%d)=timestamp;',mm,mm));
          eval(sprintf('sv%d(n%d)=unit;',mm,mm));
          eval(sprintf('nw%d(n%d)=nwords;',mm,mm));
          eval(sprintf('chid%d(n%d)=channel;',mm,mm));
          eval(sprintf('recno%d(n%d)=records;',mm,mm));
        end;
      end;
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

if do_trig, disp(sprintf('  #Events= %d (%d)',n_trg,records)); end;
disp(sprintf('  #Hits= %d (%d, ch# %d)',n,records,dchId(1)));


dt_thr=1;
nw_thr=0.9*max(nw);
tmpi=find(nw>0.9*nw_thr);
tmpi2=find(diff(tmpi)>dt_thr);
tmp_tt=[tt(1) tt(tmpi(tmpi2+1))];
tmp_tt=tmp_tt-tmp_tt(1);
tmp_tt=tmp_tt/freq;

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
data.chid=chid;

data.dt_thr=dt_thr;
data.nw_thr=nw_thr;
data.tt1=tmp_tt;

if do_trig,
data.trigId=trigId;
data.n_trig=n_trg;
data.tt_trig=tt_trg;
data.sv_trig=sv_trg;
data.nw_trig=nw_trg;
data.recno_trig=recno_trg;
data.tt1_trig=(tt_trg-tt(1))/freq;
end;

if do_multich,
  for mm=2:nch,
    eval(sprintf('data.chid%d=chid%d;',mm,mm));
    eval(sprintf('data.n%d=n%d;',mm,mm));
    eval(sprintf('data.tt%d=tt%d;',mm,mm));
    eval(sprintf('data.nw%d=nw%d;',mm,mm));
    eval(sprintf('data.recno%d=recno%d;',mm,mm));
  end;
end;

