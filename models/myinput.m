function f=myinput(t,fwhm,start)
% Usage ... f=myinput(t,fwhm,start)
% My input form is sinusoidally ramped.
% NOTE: NOT EXACT

y=sin(pi*[.1 .2 .3 .4 .5]);
fu=1/8;
tu=fu*[1 2 3 4 5]; 

fs=t(2)-t(1);
f=zeros(size(t));
for m=2:length(t),
  for n=1:5,
    if ((t(m)-t(1))>=tu(n)),
      f(m)=y(n);
    end;
  end;
  if ((t(m)-t(1))>=fwhm),
    for n=1:5,
      if ((t(m)-t(1)-fwhm)>=tu(n)),
        f(m)=y(5-n);
      end;
    end;
  end;
  if ((t(m)-t(1))>=(fwhm+tu(5)-fu)),
    f(m+1)=y(1);
    last=m+10;
    break;
  end;
end;

if exist('start'),
  o=1;
  for m=1:length(t),
    if (t(m)>=start),
      f(m)=f(o);
      f(o)=0;
      o=o+1;
    end;
    if (o>=last), break; end;
  end;
end;

if nargout==0,
  plot(t,f)
end;