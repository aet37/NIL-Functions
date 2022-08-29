function [yy,ff]=fermi1d(y,co,wid,amp,dt)
% Usage ... y=fermi1d(y,co,wid,amp,dt)
%
% Fermi 1D filter, wid is about 4-5 time-constants from baseline
% Use amplitude 1 for LPF, -1 for HPF, 1 -1 for Notch, -1 1 for Band-pass
% Amplitudes different than 1 or -1 have not been tested.
%
% Ex. fermi1d(y,10,10,1);

do_loop=1;

if ~exist('amp'), amp=[]; end;
if isempty(amp), amp=1; end;

if length(y)==prod(size(y)), y=y(:); end;

if exist('dt','var'),
  df=(1/length(y))*(1/dt);
  co=round(co/df);
  wid=round(wid/df);
  wid(find(wid==0))=1;
  disp(sprintf('  actual cutoff = %f (%f; %.1f, %.1f)',co*df,wid*df,co,wid));
end;

ii=[1:length(y)]'-1;
tmpi=fftshift(ii);
tmp0=find(tmpi==0);
ii=ii-ii(tmp0);

ff=zeros(length(y),1);
for mm=1:length(co),
  ff0=1./(1+exp((abs(ii)-co(mm))/wid(mm)));
  if amp(mm)<0,
    ff0=1-abs(amp(mm))*ff0;
  else,
    ff0=amp(mm).*ff0;
  end;
  if mm==1, ff=ff0; else, ff=ff+ff0+(amp(mm-1)>0)*amp(mm-1); end;
  %clf, plot(ff), pause,
end;
ff=ff-mm+1;
ff=fftshift(ff);

yy=zeros(size(y));
if do_loop,
  if length(size(y))==3,
    for mm=1:size(y,1), for nn=1:size(y,2),
      yf=fft(squeeze(y(mm,nn,:)));
      yff=abs(yf).*ff.*exp(j*angle(yf)+j*angle(ff));
      yy(mm,nn,:)=ifft(yff);
    end; end;
  else,
    for mm=1:size(y,2),
      yf=fft(y(:,mm));
      yff=abs(yf).*ff.*exp(j*angle(yf)+j*angle(ff));
      yy(:,mm)=ifft(yff);
    end;
  end;
else,
  if length(size(y))==3,
    yf=fft(y,[],3);
    fr=reshape(repmat(ff(:),[size(y,1)*size(y,2) 1]),size(y));
    %size(yf), size(fr),
    yff=abs(yf).*fr.*exp(j*angle(yf)+j*angle(fr));
    yy=ifft(yff,[],3);      
  else,
    yf=fft(y,[],1);
    fr=repmat(ff(:),[1 size(y,2)]);
    yff=abs(yf).*fr.*exp(j*angle(yf)+j*angle(fr));
    yy=ifft(yff,[],1);
  end;
end;
clear yf fr yff

if isreal(y), yy=real(yy); end;

if nargout==0,
  subplot(311),
  plot(ii(:),fftshift([abs(fft(y(:,1)-mean(y(:,1))))]))
  grid on, axis tight,
  subplot(312),
  plot(ii(:),[fftshift(ff(:))])
  grid on, axis tight,
  subplot(313),
  plot([1:length(y)],[y(:,1) yy(:,1)])
  grid on, axis tight,
end;

