function y=myspecgram(x,wlen)
% Usage ... y=myspecgram(x,wlen)
%

if (length(wlen)==1),
  ww=ones(1,wlen); ww=ww(:);
else,
  ww=wlen;
  wlen=length(ww);
end;

y=zeros(length(x),wlen);

for mm=1:length(x)-wlen+1,
  y(mm,:)=(fft(x(mm:mm+wlen-1).*ww)).';
end;

if (nargout==0),
  show((abs(y).^2)')
  xlabel('Time')
  ylabel('Frequency')
  clear y
end;

