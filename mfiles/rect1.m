function y=rect1(t,t0,w)
% Usage ... y=rect(t,t0,w)

if w<0,
  disp('  warning: w must be positive, taking absolute value...');
  w=abs(w);
end;

if length(t0)>1,
  t=t(:);
  y=zeros(length(t),length(t0));
  for mm=1:length(t),
    ii=find(((t-t0(mm))>=0)&((t-t0(mm))<w));
    y(ii,mm)=1;
  end;
else,
  y=zeros(size(t));
  ii=find(((t-t0)>=0)&((t-t0)<w));
  y(ii)=1;
end;

if nargout==0,
  plot(t,y),
  clear y
end;
