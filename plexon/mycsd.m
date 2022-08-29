function csd_st=mycsd(lfp,t,d,parms)
% Usage ... csd=mycsd(lfp,t,d,parms)
%
% lfp = lfp data where the columns form the depth recordings
% t = time vector
% d = depth vector
% parms = [ dt fco fw ] where dt is the final sampling time (eg 5e-4), fco is
%   the filter cut-off (eg 50hz) and fw is the filter width (eg 10hz)

if sum(d>=0)==length(d), d=-d; end;

do_filter=0;
if length(parms)==3,
  do_filter=1;
  csd_dt=parms(1);
  csd_fco=parms(2);
  csd_fcow=parms(3);
end;

dt=t(2)-t(1);

% check for nan's and remove if any
tmpsum=sum(lfp,2);
tmpnan=find(isnan(tmpsum)); 
if ~isempty(tmpnan),
  tmpi=find(~isnan(tmpsum));
  tmptt=[t(tmpi(1)):dt:t(tmpi(end))]';
  disp(sprintf('  warning: nan''s found (%d), readjusting time to [%.4f,%.4f]',length(tmpnan),tmptt(1),tmptt(end)));
  tmplfp=interp1(t(tmpi),lfp(tmpi,:),tmptt);
  clear t lfp
  t=tmptt;
  lfp=tmplfp;
end;

% filter data (for like 60 Hz)
if do_filter,
  for mm=1:size(lfp,2),
    lfp_f(:,mm)=fermi1d(lfp(:,mm),csd_fco,csd_fcow,1,dt);
  end;
else,
  lfp_f=lfp;
end;

% downsample data if necessary
if csd_dt>dt,
  ti=[t(1):csd_dt:t(end)]';
  lfp_i=interp1(t,lfp_f,ti);
else,
  disp(sprintf('  warning: lfp data not downsampled'));
  ti=t;
  csd_dt=dt;
  lfp_i=lfp_f;
end;

% subtract mean of each channel data and calc csd
lfp0_i=mean(lfp_i,1);
lfp_i=lfp_i-ones(size(lfp_i,1),1)*lfp0_i;
csd=-del2(lfp_i,d,ti)/4;
csd2=-diff(lfp_i,2,2);
[tmpgx,tmpgy]=gradient(lfp_i,d,ti);
[tmpgx2,tmpgy2]=gradient(tmpgx,d,ti);
[tmpgx22,tmpgy22]=gradient(tmpgy,d,ti);
csd4=-tmpgx22;
csd3=-tmpgx2;

% recalculate time and depth vectors
csd_t=ti;
csd_d=d;
csd2_d=d(2:end-1);
csd2_t=ti;

lfp0=mean(lfp,1);
lfp=lfp-ones(size(lfp,1),1)*lfp0;

% copy to structure
csd_st.t=ti;
csd_st.d=d;
csd_st.lfp=lfp_i;
csd_st.csd=csd3;
csd_st.parms=parms;
csd_st.csd2=csd2;
csd_st.t2=csd2_t;
csd_st.d2=csd2_d;
csd_st.t_orig=t;
csd_st.lfp_orig=lfp;

% upsample for presentation only -- myplotcsd only

% display if necessary
if nargout==0,
  subplot(211)
  mesh(csd2_t,csd2_d,csd2'),
  view(2),
  shading interp,
  axis tight,
  %tmpax=axis; axis([-0.02 0.05 tmpax(3:4)]),
  subplot(212)
  mesh(csd_t,csd_d,csd3'/csd_dt),
  view(2),
  shading interp,
  axis tight,
  %xlabel('Time'), ylabel('Depth'),
  %tmpax=axis; axis([-0.02 0.05 tmpax(3:4)]),
  clear csd
end;

