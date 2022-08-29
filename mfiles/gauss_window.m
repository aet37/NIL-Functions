function f=gauss_window(dim,mean,std,amp)
% Usage ... f=gauss_window(dim,mean,std,amp)
% 
% Calculates the gaussian window with mean, std
% and amplitude. It may 1D or 2D.

if length(dim)==2, d2=1; else, d2=0; end;
if length(mean)==2, d2=22; end;
if nargin<4, amp=1/(sqrt(2*pi*std*std')); end;

if (d2==2),
  for m=1:dim(1),
    for n=1:dim(2),
      f(m,n)=amp*exp(-0.5*(([m n]-mean)*([m n]-mean)')/(std*std'));
    end;
  end;
elseif (d2==22),
  for m=1:dim(1),
    f1(m)=amp*exp(-0.5*(m-mean(1))*(m-mean(1))/(std(1)*std(1)));
  end;
  for m=1:dim(2),
    f(:,m)=f1*amp*exp(-0.5*(m-mean(2))*(m-mean(2))/(std(2)*std(2)));
  end;
else,
  for m=1:dim,
    f(m)=amp*exp(-0.5*(m-mean)*(m-mean)/(std*std));
  end;
end;

