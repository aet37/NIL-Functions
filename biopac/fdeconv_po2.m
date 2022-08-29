function [xd,xdi]=fdeconv_po2(y,tau,dt,fco)
% Usage ... corr_data=fdeconv_po2(data,tau,dt,fco--optional)
%
% Returns a corrected PO2 data for temporal lags due to
% the temporal response of the PO2 sensor. A cut-off filter
% at 5Hz is used by default.
% Beware, fourier deconvolution is very noisy and adds ringing to
% data, so use on raw data first, then piece out trials and average


if nargin<4, fco=4; end;
ff0=round(length(y)*fco(1)*dt);
fco_act=ff0/(dt*length(y));

y=y(:);
t=([0:length(y)-1]')*dt;

if length(tau)==1,
  h=exp(-t/tau);
else,
  h=tau;
end;

% add fermi option
ff=zeros(size(y));
ff(1:ff0)=1;
ff(end-ff0+1:end)=1;

yf=fft(y);
hf=fft(h)/sum(h);

xdf=yf./hf;
xdf=ff.*xdf;

xd=ifft(xdf);

xdi=imag(xd);
xd=real(xd);

if nargout==0,
  plot(t,y,t,xd)
  axis('tight'), grid('on'),
  legend('data','corrected')
end;

