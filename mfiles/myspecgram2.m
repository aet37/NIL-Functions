function [y,yi]=myspecgram2(x,wlen,wskip,nspec,wfilt,tt)
% Usage ... [y,yi]=myspecgram2(x,wlen,wskip,nspec,wfilt,tt)

if nargin<3, wskip=1; end;
if nargin<4, nspec=wlen; end;
if nargin<5, wfilt=ones(wlen,1); end;

if length(nspec)==2,
  fco=nspec(1);
  fs=nspec(2);
  nspec=round(wlen*fco/fs);
  ff=[0:nspec-1]*fco/nspec;
else,
  ff=[0:nspec-1];
  fs=1;
end;

if ~exist('tt'), tt=[1:length(x)]; end;

x=x(:);
do_power=0;
do_window=1;

ny=floor(length(x)/wskip);
ny=ny-ceil(wlen/wskip);

for mm=1:ny,
  tmpii=[1:wlen]+(mm-1)*wskip;
  %[mm ny tmpii([1 end])],
  tmp=x(tmpii);
  if do_window, tmp=tmp.*hamming(wlen); end;
  tmpf=fft(tmp).*wfilt;
  if do_power, tmpf=tmpf.^2; end;
  y(:,mm)=abs(tmpf(1:nspec));
  yi(mm)=tmpii(1);
  tw(mm)=mean(tt(tmpii));
  %tw(mm)=tt(tmpii(end));
end;

if nargout==0,
  imagesc(tw,ff,y)
  axis('xy'),
  xlabel('Time')
  ylabel('Frequency')
end;

