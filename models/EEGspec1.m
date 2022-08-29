function y=EEGspec1(data,fs,t_win,t_skp,parms,f_range)
% Usage ... y=EEGspec1(data,fs,t_win,t_skip,parms,f_range)
%
% Calculates the spectrogram of EEG data acquired with sampling rate fs
% over a time window with duration (t_win), every t_skip. If f_range
% is included, energy power at the specified bands is also retuned.
% By default, the last entry is half the total power (to fmax).
% parms= [bin window_type]
%
% Ex. eeg1=EEGspec1(biopacData.EEG,1000,2,0.5,5,[0.4 4.5;4.5 10.5;10.5 16.5;16.5 31;31 55]);
%     ldf1=EEGspec1(biopacData.FLUX,1000,40,2,10,[0.05 0.2;0.2 0.4;0.5 2;2 5]);

do_figures=0;
if nargout==0, do_figures=1; end;

do_frange=0;
if exist('f_range','var'), do_frange=1; end;

if ~exist('parms','var'), parms=[]; end;
if isempty(parms), parms=[1 0]; end;
if length(parms)==1, parms(2)=0; end;

nbin=parms(1);
if nbin==0, nbin=1; end;

if nbin>1,
  data=ybin2(data,nbin);
  fs=fs/nbin;
end;
tt=[1:length(data)]/fs;

psd=fft(data).^2;
psds=sum(abs(psd))/length(psd);
ff=[0:length(tt)-1]*fs/length(tt);

mt_parms.Fs=fs;
mt_parms.tapers=[5 3];  %[5 9]
mt_parms.pad=0;
[mt_S,mt_f]=mtspectrumc(data,mt_parms);

if do_figures,
  tmp_xmax=100; 
  if tmp_xmax>fs, tmp_xmax=fs/2; end;
  tmp_ymax1=max(abs(psd(find((ff>0.01)&(ff<50)))/psds));
  tmp_ymax2=max(abs(mt_S(find((mt_f>0.01)&(mt_f<50)))));
  
  figure(1), clf,
  subplot(221), plot(ff,abs(psd/psds)), axis tight, grid on, fatlines(1.5); set(gca,'XLim',[0 tmp_xmax],'YLim',[0 tmp_ymax1]),
  xlabel('Frequency'), ylabel('PSD 1'), dofontsize(16); set(gca,'FontSize',12);
  subplot(222), plot(ff,10*log10(abs(psd/psds))), axis tight, grid on, fatlines(1.5); set(gca,'XLim',[0 tmp_xmax]),
  xlabel('Frequency'), ylabel('Log10 PSD1'), dofontsize(16); set(gca,'FontSize',12);
  subplot(223), plot(mt_f,mt_S), axis tight, grid on, fatlines(1.5); set(gca,'XLim',[0 tmp_xmax],'YLim',[0 tmp_ymax2]),
  xlabel('Frequency'), ylabel('PSD2'), dofontsize(16); set(gca,'FontSize',12);
  subplot(224), plot(mt_f,10*log10(mt_S)), axis tight, grid on, fatlines(1.5); set(gca,'XLim',[0 tmp_xmax]),
  xlabel('Frequency'), ylabel('Log10 PSD2'), dofontsize(16); set(gca,'FontSize',12);
  %keyboard, disp('  press enter to continue...'), pause,
end;


n_win=floor(t_win/(tt(2)-tt(1)));
n_skp=floor(t_skp/(tt(2)-tt(1)));

win_type=parms(2);
if win_type==0,
  win=ones(1,n_win);
elseif win_type==2,
  disp('   using hanning window');
  win=hanning(n_win);
else,,
  disp('   using hamming window');
  win=hamming(n_win);
end;

ffs=[0:n_win-1]*fs/n_win;
if do_frange, 
  win_fmin=min(f_range(:));
  win_fmax=max(f_range(:));
  for nn=1:size(f_range,1), 
    f_range_ii{nn}=find((ffs>=f_range(nn,1))&(ffs<f_range(nn,2))); 
  end;
else,
  win_fmin=ffs(2);
  win_fmax=ffs/2; 
end;
win_fmini=find(ffs>=win_fmin,1);
win_fmaxi=find(ffs>=win_fmax,1);
ffs=ffs(1:win_fmaxi);

mt_parms.fpass=[0 win_fmax];
[mt_Sg,mt_Tg,mt_Fg]=mtspecgramc(data,[t_win t_skp],mt_parms);
mt_Sg_ssum=sum(abs(mt_Sg),2);
mt_Sgn=mt_Sg.*repmat(1./mt_Sg_ssum,[1 length(mt_Fg)]);

if do_frange, 
  for nn=1:size(f_range,1), 
    f_mt_range_ii{nn}=find((mt_Fg>=f_range(nn,1))&(mt_Fg<f_range(nn,2))); 
  end;
end;

spec=single(zeros(win_fmaxi,floor((length(data)-n_win)/n_skp)));
specn=single(zeros(win_fmaxi,floor((length(data)-n_win)/n_skp)));
specs=single(zeros(size(spec,2),1));
data=data/sum(data(:).^2);
for mm=1:size(spec,2),
  tmpdata=data([1:n_win]+(mm-1)*n_skp);
  tmpdata=tmpdata.*win;
  tmppsd=fft(tmpdata).^2;
  specs(mm)=sum(abs(tmppsd(:)));
  specs1(mm)=sum(abs(tmppsd(win_fmini:win_fmaxi)));
  spec(:,mm)=single(tmppsd(1:win_fmaxi));
  specn(:,mm)=single(tmppsd(1:win_fmaxi)/specs(mm));
  tts(mm)=mean(tt([1:n_win]+(mm-1)*n_skp));
end;


if do_figures,
  figure(2), clf,
  %pcolor(tts,ffs,abs(spec)),
  pcolor(tts,ffs,abs(specn)),
  axis tight, shading interp, view(2), set(gca,'CLim',[min(abs(specn(:))) 0.1*max(abs(specn(:)))]),
  colormap jet, tmph=colorbar; set(get(tmph,'label'),'string','Power','FontSize',12); clear tmph
  title('Spectrogram1'), xlabel('Time'), ylabel('Frequency'), dofontsize(16); set(gca,'FontSize',12);

  figure(3),
  %pcolor(mt_Tg,mt_Fg,abs(mt_Sg).'),
  pcolor(mt_Tg,mt_Fg,abs(mt_Sgn).'),
  axis tight, shading interp, view(2), set(gca,'CLim',[min(abs(mt_Sgn(:))) 0.1*max(abs(mt_Sgn(:)))]),
  colormap jet, tmph=colorbar; set(get(tmph,'label'),'string','Power','FontSize',12); clear tmph
  title('Spectrogram2'), xlabel('Time'), ylabel('Frequency'), dofontsize(16); set(gca,'FontSize',12);

end;

if do_frange,
  for mm=1:length(f_range_ii),
    spec_env(mm,:)=sum(abs(spec(f_range_ii{mm},:)),1);
    spec_enva(mm,:)=mean(abs(spec(f_range_ii{mm},:)),1);
    spec_mt_env(:,mm)=sum(abs(mt_Sg(:,f_mt_range_ii{mm})),2);
    spec_mt_enva(:,mm)=mean(abs(mt_Sg(:,f_mt_range_ii{mm})),2);
  end;
  spec_envs=specs(:);
  spec_envs1=specs1(:);
  spec_env=spec_env.';
  spec_enva=spec_enva.';
  spec_envn=spec_env./(spec_envs1*ones(1,size(spec_env,2)));
  spec_envan=spec_enva./(spec_envs1*ones(1,size(spec_env,2)));
  
  if do_figures,
    figure(4), clf,
    plotmany(tts,spec_env),
    figure(5), clf,
    plotmany(tts,spec_envn),
    figure(6), clf,
    plotmany(mt_Tg,spec_mt_env),
  end;
end;

y.fs=fs;
y.t_win=t_win;
y.t_skp=t_skp;
y.parms=parms;
y.psd=psd;
y.ff=ff;
y.spec=spec;
y.specs=specs;
y.specs1=specs1;
y.ffs=ffs;
y.tts=tts;
y.win_type=win_type;
y.mt_parms=mt_parms;
y.mt_spec=mt_Sg;
y.mt_spec_ssum=mt_Sg_ssum;
y.mt_tt=mt_Tg;
y.mt_ff=mt_Fg;

if do_frange,
  y.f_range=f_range;
  y.f_range_ii=f_range_ii;
  y.spec_env=spec_env;
  y.spec_enva=spec_enva;
  y.spec_envn=spec_envn;
  y.spec_envan=spec_envan;
  y.spec_env_mt=spec_mt_env;
  y.spec_enva_mt=spec_mt_enva;
end;
