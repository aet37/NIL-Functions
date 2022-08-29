function f=mypulse(t,width,amp,start)
% Usage ... f=mypulse(t,width,amp,start)
% Returns a vector f the size of t with pulses of
% width as specified by two column values. The number
% of pulses is specified by the number of rows.

t=t(:);

tmp=zeros(size(t));

for m=1:length(tmp),
  if ((t(m)>=start)&(t(m)<=(start+width))),
    tmp(m)=1;
  end;
end;

f=amp.*tmp;

if nargout==0,
  plot(t,tmp);
end;