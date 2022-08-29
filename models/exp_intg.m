function [g,i]=exp_intg(x,t,start,w,biasi)
% Usage ... [g,i]=exp_intg(x,t,start_flag,y,bias_index_range)
%
% x - 3 parameters: mean, std, amp
% start flag stores the location of the start of the waveform in i

mean=x(1);
std=x(2);
amp=x(3);

t=t(:);
f=amp*exp(-((t-mean)/(2*std)).^2);

g(1)=(1/((4*pi*std*std)^(0.5)))*f(1);
for m=2:length(f),
  g(m)=(1/((4*pi*std*std)^(0.5)))*trapz(t(1:m),f(1:m));
end;
g=g(:);

if start,
  indx=0;
  for m=1:length(g),
    if g(m)>0,
      indx=m;
      break;
    end;
  end;
  i=indx;
end;

if nargin>3,
  z=w-g;
  if ~exist('biasi'),
    biasi=[1:length(z)];
  end;
  f=z(biasi(1):biasi(2));
  plot(t,w,t,g)
  sse=sum(f);
  disp(['Mean: ',num2str(mean,6),' - Std: ',num2str(std,6),' - Amp: ',num2str(amp,6),' - SSE: ',num2str(sse,6)]);
  g=f;
end;

if (nargout==0)&(nargin<4),
  plot(t,g);
  if start,
    disp(['Start at index: ',int2str(i),' - x= ',num2str(t(i),2)]);
  end;
end;