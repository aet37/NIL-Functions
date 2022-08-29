function [g,i]=tri_intg(x,t,w,biasi)
% Usage ... [g,i]=tri_intg(x,t,start_flag,y,bias_index_range)
%
% x - 2 parameters: width, lag, amplitude
% t - time vector for reference
% w - reference waveform
% bias - part for error

width=x(1);
lag=x(2);
amp=x(3);

t=t(:);
f=tri(t,width,lag);

g(1)=f(1);
for m=2:length(f),
  g(m)=trapz(t(1:m),f(1:m));
end;
g=(amp/max(g))*g;
g=g(:);

if nargin>2,
  z=w-g;
  if ~exist('biasi'),
    biasi=[1:length(z)];
  end;
  f=z(biasi(1):biasi(2));
  plot(t,w,t,g)
  sse=sum(f);
  disp(['Width: ',num2str(width,6),', Lag: ',num2str(lag,6),', Amp: ',num2str(amp,6),' - SSE: ',num2str(sse,6)]);
  g=f;
end;

if (nargout==0)&(nargin<3),
  plot(t,g);
end;
