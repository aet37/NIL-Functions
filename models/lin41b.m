function [z,w,v]=lin41b(x,u,t,parms,parms2fit,nnumden,y,wc)
% [z,w]=lin41b(x,u,parms,parms2fit,nnumden,y,w)
%
% This function outputs a linear system response to input U
% and system with zeros and poles in x (nnumden=[#zeros #poles]).
% The last two entries in x are [Gain X-shift]


verbose_flag=0;

if (length(x)>0),
  parms(parms2fit)=x;
end;

t=t(:);
u=u(:);

dt=t(2)-t(1);
tl=length(t);
ul=length(u);

% Transfer Function Parameters
%   a1=3.8; a2=.2;
%   b1=4; b2=2; b3=.5;

%% Filtering function initialization and selection
%vst=parms(1);
%vramp=parms(2);
%vdur=parms(3);
%v=mytrapezoid3(t,vst+vramp,vdur,vramp);
%
%vnormalize=1;
%if (vnormalize),
%  v=v/trapz(t,v);
%end;
%
%w=myconv(u,v);
w=u(:);

% Calculate system response using mysol function,
%  assume zero initial conditions.
if nnumden(1)==0,
  num=[1];
  if verbose_flag, disp(sprintf('  num= %.4f',num(1))); end;
elseif nnumden(1)==1,
  num=[1 -1*parms(1)];
  if verbose_flag, disp(sprintf('  num= [1 %.4f]',num(2))); end;
else,  %nnumden(1)>1
  num=[1 -1*parms(1)];
  for mm=2:nnumden(1),
    num=conv(num,[1 -1*parms(mm)]);
  end;
  if verbose_flag, disp('  [',num2str(num(:)'),']'); end;
end;

if nnumden(2)==0,
  den=1;
  if verbose_flag, disp(sprintf('  den= %.4f',den(1))); end;
elseif nnumden(2)==1,
  den=[1 -1*parms(nnumden(1)+1)];
  if verbose_flag, disp(sprintf('  den= [1 %.4f]',den(2))); end;
else, %nnumden(2)>1
  den=[1 -1*parms(nnumden(1)+1)];
  for mm=2:nnumden(2),
    den=conv(den,[1 -1*parms(nnumden(1)+mm)]);
  end;
  if verbose_flag, disp(['  den= [',num2str(den(:)'),']']); end;
end;

amp=parms(end-1);
t0=parms(end);

z=mysol(num,den,w,t);
z=amp*z(:);

if t0,
  z=tshift2(z,t0*dt);
end;

if (nargin>6),
  err=y(:)-z;
  errn=length(err);
  if (nargin>7),
    err=err.*wc(:);
    errn=sum(abs(wc)>0);
  end;
  %err=err/max(y-1);
  %err=err/errn;
  [sum(err.^2)],
  zorig=z;
  z=err;
end;

if (nargout==0),
  subplot(311)
  plot(t,u(:))
  ylabel('Input')
  subplot(312)
  plot(t,[y(:) zorig(:)])
  ylabel('Output'),
  subplot(313)
  plot(t,z(:))
  ylabel('Error'),
end;

