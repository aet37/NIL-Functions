function y=EEGsleep1(data,f_range,spec_parms,sleep_parms,emg_data)
% Usage ... y=EEGsleep1(data,f_range,spec_parms,sleep_parms)
%
% this function uses EEGspec1
% spec_parms=[fs, t_win, t_skip, nbin, wintype]
% sleep_parms=[t_sleepwin, thr_ratio]
%
% Ex. EEGsleep1(y_str,[1 2],[10 1.0])

do_figures=1;

do_spec=1;
if isstruct(data),
  do_spec=0;
end;

if do_spec,
  f_range=[f_range; 0.5 4.5; 4.5 10; 10 16; 16 25; 25 55];

  fs=spec_parms(1);
  t_win=spec_parms(2);
  t_skp=spec_parms(3);
  n_bin=spec_parms(4);
  win_type=spec_parms(5);
  t_sleepwin=sleep_parms(1);

  ys=EEGspec1(data,fs,t_win,t_skp,[nbin wintype],f_range);
  
  ts=ys.tts;
  nsm=floor(t_sleepwin/t_skp);
  yfr=mysmooth(ys.spec_enva(:,1)./ys.spec_enva(:,2),nsm);
else,
  if exist('sleep_parms','var'), 
      emg_data=sleep_parms; 
      clear sleep_parms 
  end;
  sleep_parms=spec_parms;

  fr_range=data.f_range;
  
  fs=data.fs;
  t_win=data.t_win;
  t_skp=data.t_skp;
  n_bin=data.parms(1);
  win_type=data.parms(2);
  t_sleepwin=sleep_parms(1);
  spec_pamrs=[fs t_win t_skp n_bin win_type];
  
  ts=data.tts;
  nsm=floor(t_sleepwin/t_skp);
  yfr=mysmooth(data.spec_enva(:,f_range(1))./data.spec_enva(:,f_range(2)),nsm);
end;

if length(sleep_parms)>1,
  fr_thr=sleep_parms(2);
else,
  fr_thr=1.2;
end;

dthr=2;
yfr_ii=find(yfr>fr_thr);
if isempty(yfr_ii), warning('  no criteria met threshold'); end;

nslp=floor(t_sleepwin/t_skp);
yfr_il=single(zeros(size(yfr_ii)));
yfr_is=single(zeros(size(yfr_ii)));
cnt=1; yfr_il(cnt)=1;
for mm=2:length(yfr_ii),
  if round(yfr_ii(mm)-yfr_ii(mm-1))==1,
    yfr_il(mm)=cnt;
  elseif round(yfr_ii(mm)-yfr_ii(mm-1))>dthr,
    cnt=cnt+1;
    yfr_il(mm)=cnt;
  else,
    yfr_il(mm)=0;
  end;
end;

yfr_ss=[];
yfr_s1=[];
cnt=0;
for mm=1:max(yfr_il(:)),
  tmpii=find(yfr_il==mm);
  yfr_in(mm)=length(tmpii);
  if yfr_in(mm)>=nslp,
    cnt=cnt+1;
    slp_ii(cnt)=mm;
    yfr_is(tmpii)=1;
    yfr_ss=[yfr_ss;yfr_ii(tmpii)];
    yfr_s1=[yfr_s1;yfr_ii(tmpii(1))];
  end;
end;

if ~isempty(yfr_s1),
  yfr_st=ts(yfr_s1);
else,
  disp('  no thr segments found'),
  yfr_st=[];
end;

% yfr is the specEnv ratio
% yfr_ii are the locations exceeding the thr
% yfr_in is the number of contigous indeces
% yfr_is is the logical entry of sleep episodes
% yfr_ss is the indeces of sleep episodes
% yfr_s1 is the first entry for each episode
% yfr_st is the time of each first episode

if do_figures,
  figure(5), clf,
  subplot(311), plot(ts,data.spec_enva(:,1)), axis tight, grid on,
  xlabel('Time'), ylabel('SpecEnv1'), dofontsize(16); set(gca,'FontSize',12);
  subplot(312), plot(ts,data.spec_enva(:,2)), axis tight, grid on,
  xlabel('Time'), ylabel('SpecEnv2'), dofontsize(16); set(gca,'FontSize',12);
  subplot(313), plot(ts,yfr), axis tight, grid on,
  xlabel('Time'), ylabel('SpecEnvRatio'), dofontsize(16); set(gca,'FontSize',12);
  
  figure(6), clf,
  subplot(311), plot(ts,log10(data.spec_enva(:,1))), axis tight, grid on,
  xlabel('Time'), ylabel('Log SpecEnv1'), dofontsize(16); set(gca,'FontSize',12);
  subplot(312), plot(ts,log10(data.spec_enva(:,2))), axis tight, grid on,
  xlabel('Time'), ylabel('Log SpecEnv2'), dofontsize(16); set(gca,'FontSize',12);
  subplot(313), plot(ts,log10(data.spec_enva(:,1))./log10(data.spec_enva(:,2))), axis tight, grid on,
  xlabel('Time'), ylabel('Log SpecEnvRatio'), dofontsize(16); set(gca,'FontSize',12);

  figure(7), clf,
  subplot(231), hist(yfr), axis tight, grid on,
  xlabel('Ratio'), ylabel('Number (#)'), dofontsize(16); set(gca,'FontSize',12);
  subplot(232), hist(yfr_in*t_skp), axis tight, grid on,
  xlabel('TotalEp Time'), ylabel('Number (#)'), dofontsize(16); set(gca,'FontSize',12);
  subplot(233), hist(yfr_in(slp_ii)*t_skp), axis tight, grid on,
  xlabel('SleepEp Time'), ylabel('Number (#)'), dofontsize(16); set(gca,'FontSize',12);
  subplot(212), plot(ts,yfr,ts(yfr_ss),yfr(yfr_ss),'rx'), axis tight, grid on,
  xlabel('Time'), ylabel('SpecEnvRatio'), dofontsize(16); set(gca,'FontSize',12);
  %subplot(212), plot(ts,yfr,ts(yfr_ii(yfr_is)),yfr(yfr_ii(yfr_is)),'rx'), axis tight, grid on,
  
  if exist('emg_data','var'),
    tt_emg=[1:length(emg_data)]/1000;
    
    slp_raster=zeros(size(yfr));
    slp_raster(yfr_ss)=1;
    
    figure(8), clf,
    subplot(331), hist(yfr), axis tight, grid on,
    xlabel('Ratio'), ylabel('Number (#)'), dofontsize(16); set(gca,'FontSize',12);
    subplot(332), hist(yfr_in*t_skp), axis tight, grid on,
    xlabel('TotalEp Time'), ylabel('Number (#)'), dofontsize(16); set(gca,'FontSize',12);
    subplot(333), hist(yfr_in(slp_ii)*t_skp), axis tight, grid on,
    xlabel('SleepEp Time'), ylabel('Number (#)'), dofontsize(16); set(gca,'FontSize',12);
    subplot(312), plot(ts,yfr,ts(yfr_ss),yfr(yfr_ss),'rx'), axis tight, grid on,
    xlabel('Time'), ylabel('SpecEnvRatio'), dofontsize(16); set(gca,'FontSize',12);
    subplot(313), plot(tt_emg,emg_data), axis tight, grid on,
    %subplot(313), plot(tt_emg,emg_data,tt_emg(tmpeii),emg_data(tmpii)), axis tight, grid on,
    xlabel('Time'), ylabel('EMG (mV)'), dofontsize(16); set(gca,'FontSize',12);
  end
end;

if nargout>0,
  y.spec_parms=spec_parms;
  y.sleep_parms=sleep_parms;
  y.f_range=fr_range;
  y.spec_ratio=yfr;
  y.f_ratio=fr_thr;
  y.n_sleep=nslp;
  y.is=yfr_ii;
  y.is_n=yfr_in;
  y.ts=ts(yfr_ii);
  y.ts_n=yfr_in*(ts(2)-ts(1));
  
  y.is=yfr_is;
  y.ss=yfr_ss;
  y.is1=yfr_s1;
  y.ts1=yfr_st;
end;

  