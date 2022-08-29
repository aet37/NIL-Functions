function [y,arc]=myarfilt(x,ord)
% Usage ... [y,arcoeffs]=myarfilt(x,order)

if prod(size(x))>length(x),
  for nn=1:size(x,2),
    arc(nn,:)=aryule(x(:,nn)-mean(x(:,nn)),ord);
    y(:,nn)=filter(arc(nn,:),1,x(:,nn)-mean(x(:,nn)));
  end;
else,
  x=x(:);
  arc=aryule(x-mean(x),ord);
  y=filter(arc,1,x-mean(x))+mean(x);
end;

if nargout==0,
  n=randn(size(x(:,1)));
  nf=filter(arc(1,:),1,n);
  subplot(411)
  plot([x(:) y(:)])
  axis('tight'), grid('on'),
  legend('data',sprintf('AR filtered (%d)',ord)),
  subplot(412)
  plot([abs(fft(x(:)-mean(x(:))))]),
  axis('tight'), grid('on'),
  legend('Data'),
  subplot(413)
  plot([abs(fft(y(:)-mean(y(:))))])
  %plot([abs(fft(x(:)-mean(x(:)))) abs(fft(y(:)-mean(y(:)))) abs(fft(nf(:)-mean(nf)))])
  axis('tight'), grid('on'),
  legend(sprintf('AR Filtered (%d)',ord)),
  subplot(414)
  plot([abs(fft(n)) abs(fft(nf))]),
  axis('tight'), grid('on'),
  legend('white noise',sprintf('AR filtered (%d)',ord))

  clear y arc n nf
end;

