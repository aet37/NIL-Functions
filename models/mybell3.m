function f=mybell1(t,width)
% Usage ... f=mybell1(t,width)
% Bell function construction of the type
% hamming the resulting vector will have 
% size t (width=fwhm).

tl=length(t);
fs=1/(t(2)-t(1));
tmp=zeros(size(t));

tmp=hamming(round(2*width*fs));
for n=length(tmp):length(t), tmp(n)=0; end;

f=tmp;

if (nargout==0), plot(t,f); end;