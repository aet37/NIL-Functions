function [y,y2]=lfpspk_filt(x,fco,fs,nord)
% Usage ... y=lfpspk_filt(x,fco,fs,ord)

dofft=0;
if ~exist('notd','var'), nord=1; end;
if ~exist('fs','var'), fs=20e3; end;

if isstr(fco),
  if strcmp(fco,'lfp'),
    fco=[10 150];
  elseif strcmp(fco,'spk'),
    fco=[500 fs/2.02];
  end;
end;

if isempty(x),
  dofft=1;
  x=randn(fs,200);
end;

[b,a]=butter(nord,2.0*fco/fs);
y=filter(b,a,x);
y2=filtfilt(b,a,x);
% do not use filtfilt

if nargout==0,
  clf,
  plot(y)
end;

if dofft,
  subplot(211),
  plot([1:fs],[mean(abs(fft(x)),2) mean(abs(fft(y)),2) mean(abs(fft(y2)),2)]),
  ylabel('Magnitude (a.u.)'), grid('on'), axis('tight'),
  tmpax=axis; axis([0 2*max(fco) 0 tmpax(4)]),
  subplot(212),
  plot([1:fs],[mean(unwrap(angle(fft(x))),2)-mean(unwrap(angle(fft(y))),2)]),
  %plot([1:fs],[mean(unwrap(angle(fft(x))),2) mean(unwrap(angle(fft(y))),2)]),
  ylabel('Phase (rad)'), grid('on'), axis('tight'),
  xlabel('Frequency (Hz)'),
  tmpax=axis; axis([0 2*max(fco) tmpax(3:4)]),
end;

