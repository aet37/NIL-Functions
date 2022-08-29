function y=myFreqCoh(x1,x2)
% Usage ... y=myFreqCoh(x1,x2)

G12=abs(fft(xcorr(x1,x2)));
G11=abs(fft(xcorr(x1,x1)));
G22=abs(fft(xcorr(x2,x2)));

y=G12.^2;
y=y./(G11.*G22);

G12f=abs(fft(x1).*fft(x2));
G11f=abs(fft(x1).^2);
G22f=abs(fft(x2).^2);
yf=(G12f.*G12f)./(G11f.*G22f);

tmpthr=sqrt(1e3*eps);
tmpii1=[1:floor(length(G11f)/2)];
tmpii0=find((G11f(tmpii1)<tmpthr)|(G22f(tmpii1)<tmpthr));
tmpii9=find((G11f(tmpii1)>tmpthr)|(G22f(tmpii1)>tmpthr));
if min(tmpii9)<(length(G11f)/4), 
  tmpi1=[1:max(tmpii9)];
else,
  tmpi1=[min(tmpii9):round(length(G11f)/2)];
end;

yf(tmpii0)=0;
y(tmpii0)=0;

if nargout==0,
  figure(1), clf,
  subplot(221),
  plot(tmpi1,G11(tmpi1)),
  subplot(222),
  plot(tmpi1,G22(tmpi1)),
  subplot(223),
  plot(tmpi1,G12(tmpi1)),
  subplot(224),
  plot(tmpi1,y(tmpi1))
  
  figure(2), clf,
  subplot(221),
  plot(tmpi1,G11f(tmpi1)),
  subplot(223),
  plot(tmpi1,G22f(tmpi1)),
  subplot(222),
  plot(tmpi1,G12f(tmpi1))
  subplot(224),
  plot(tmpi1,yf(tmpi1))

  clear y
end

