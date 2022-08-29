function yi=sl_timecorr(x,path,slno,info,xi,type,intopts,write,ext)
% Usage ... yi=sl_interp1(x,path,slno,info,xi,type,intopts,write,ext)
%
% types: 1- linear, 2- spline, 3- sinc (type index)
% intopts: linear (no opts), spline (no opts), sinc (winsize wintype)
% write: yes= default

if (nargin<9), ext=''; end;
if (nargin<8), write=1; end;
if (nargin<7), intopts=[2 2]; end;
if (nargin<6), type=[3 1]; end;

if (isempty(ext)), ext2=''; else, ext2=[ext,'.']; end;

plotflag=0;

nn=intopts(1);
wintype=intopts(2);
if (length(intopts)<3), intopts(3)=1; end;

if length(type)==1, type(2)=1; end;

intkertype=type(1);
intkeropt=type(2);

for m=1:length(xi),
  Xi=find(abs(xi(m)-x)<=nn);
  if isempty(Xi), error('Can not find any point to interpolate!'); end;
  X=x(Xi);
  if (intkertype==3),		% sinc interpolation
    if wintype==1, WIN=0.54+0.46*cos(pi*(X-xi(m))/nn);
    elseif wintype==2, WIN=0.5*(1+cos(pi*(X-xi(m))/nn));
    elseif wintype==3, WIN=(cos((pi/4)*(X-xi(m))/nn)).^3;
    else, WIN=1;
    end;
    W=sinc((X-xi(m))/intopts(3)).*WIN;
  elseif (intkertype==2),		% cubic interpolation
    for mm=1:length(X),
      xx=abs(X(mm)-xi(m))/intopts(2);
      if (xx<=1),
        W(mm) = 1 - (5/2)*(xx^2) + (3/2)*(xx^3);
      elseif (xx<=2),
        W(mm) = 2 - 4*xx + (5/2)*(xx^2) - (1/2)*(xx^3);
      else,
        W(mm) = 0;
      end;
    end;
  else,				% linear interpolation
    W=1-abs(X-xi(m))/nn;
  end;
  SW=sum(W); if (SW==0.0), SW=1.0; end;
  if (plotflag), plot(X-xi(m),W,'*'), pause, end;
  yi=zeros([info(1) info(2)]);
  for n=1:length(Xi),
    disp(sprintf(' interpolating im# %d using im# %d',xi(m),x(Xi(n))));
    if (intkeropt==2),
      yi=yi+(W(n)/SW)*getslim(path,slno,x(Xi(n)),info,ext);
    else,
      yi=yi+(W(n)/SW)*getslim(path,slno,Xi(n),info,ext);
    end;
  end;
  if (write),
    if m>999,
      outname=sprintf('%ssl%d.%s%04d',path,slno,ext2,round(xi(m)));
    else,
      outname=sprintf('%ssl%d.%s%03d',path,slno,ext2,round(xi(m)));
    end;
    if (length(info)>2),
      if info(3)==1, writeim(outname,round(yi),'short','b');
      else, writeim(outname,round(yi));
      end;
    else, writeim(outname,round(yi));
    end;
  end;
end;

