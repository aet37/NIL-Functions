function [t0,t0s,t0m,t0p]=onset_stats1(y,t,parms,fitparms)
% Usage .. [t0,t0s,t0m,t0p]=onset_stats1(y,t,parms,fitparms)
% 
% parms=[i0(1) i0(2) i1(1) i1(2) nmax onthr(1) onthr(2) nstd]
% fitparms=[t_u0 t_u1 t_y0 t_y1 max_t0]

verbose_flag=0;
if nargin>3, do_fit=1; else, do_fit=0; end;

if nargin==1,
  t=[1:length(y)];
  parms=[1 10 3 0.2 0.8 2];
end;
i0=parms(1:2);
i1=parms(3:4);
nmax=parms(5);
onthr=parms(6:7);
nstd=parms(8);

ii0=[i0(1):i0(2)];
y0mean=mean(y(ii0));
y0std=std(y(ii0));

[tmpmax,tmpmaxi]=max(y(i1(1):i1(2)));
tmpmaxi=tmpmaxi+i1(1)-1;
if nmax>1,
  ii=round(nmax/2);
  y_max=mean(y(tmpmaxi+[-ii:ii]));
else,
  y_max=tmpmax;
end;
y_maxi=tmpmaxi;

y_norm=normch(y,y0mean,y_max);
i1=find(y_norm<=onthr(1));
i2=find(y_norm>=onthr(2));
i1=i1(find(i1<i2(1)));

y_norm2=y_norm(i1(end):i2(1));
t_norm2=t(i1(end):i2(1));
t1=interp1(y_norm2,t_norm2,onthr(1));
t2=interp1(y_norm2,t_norm2,onthr(2));

mm0=(onthr(2)-onthr(1))/(t2-t1);
bb0=onthr(1)-mm0*t1;
t0=-bb0/mm0;
yy0=mm0*t+bb0;

pp=polyfit(t_norm2(:),y_norm2(:),1);
t0p=-pp(2)/pp(1);
yyp=polyval(pp,t);

ii=find(t>=0);
tt=t(ii);
is=find(y(ii)>=(y0mean+nstd*y0std));
if ~isempty(is), t0s=tt(is(1)); else, t0s=[]; end;
%keyboard,

if do_fit,
  xopt=optimset('lsqnonlin');
  xopt.TolFun=1e-10;
  xopt.TolX=1e-4;
  %xopt.MaxIter=1000;
  %xopt.Display='iter';
  fi=fitparms;
  imax=fitparms(5)/(t(2)-t(1));
  xg=[3 2 1];
  xlb=[0 1e-4 0.7];
  xub=[imax 8 1.3];
  x2fit=[1 2 3];
  u=zeros(size(t)); ui=find((t>=fi(1))&(t<=fi(2))); u(ui)=1;
  yi=find((t>=fi(3))&(t<=fi(4)));
  y_norm=y_norm(:); t=t(:); u=u(:);
  xx=lsqnonlin(@myfirstode,xg(x2fit),xlb(x2fit),xub(x2fit),xopt,xg,x2fit,t(yi),u(yi),y_norm(yi));
  ym=myfirstode(xx,xg,x2fit,t,u);
  xg(x2fit)=xx;
  %t0m=xx(1)*(t(2)-t(1));
  t0m=xx(1);
else,
  t0m=0;
end;
%keyboard,

if nargout==0,
  if verbose_flag,
    disp(sprintf('  baseline:  mean/std= %.3f/%.3f',y0mean,y0std));
    disp(sprintf('  max/tmax= %.3f/%.3f',y_max,t(y_maxi)));
    disp(sprintf('  tonset/tonstd= %.3f/%.3f(%.3f)',t0,t0s,nstd*y0std));
  end;
  figure(1)
  plot(t,y_norm,t,yy0,[t0 t1 t2],[0 onthr(1) onthr(2)],'x',t0s,y_norm(ii(1)+is(1)-1),'o',t,yyp)
  axis([t(1) t(end) min(y_norm) max(y_norm)]), grid('on'), 
  title(sprintf('tonset/tonstd= %.3f/%.3f(%.3f)',t0,t0s,nstd*y0std));
  if do_fit,
    hold('on'),
    plot(t,ym,'r')
    xlabel(sprintf('t0 model= %.3f (tau=%.3f, amp=%.3f)',t0m,xg(2),xg(3)));
    hold('off'),
    legend('data','line','onset','onset std','fit')
  end;
end;


function my=myfirstode(x,parms,parms2fit,mt,mu,mz)
  verb_flag=0;
  if ~isempty(x), parms(parms2fit)=x; end;
  mt0=parms(1); mtau=parms(2); mamp=parms(3);
  my=zeros(size(mt)); dt=mt(2)-mt(1);
  for mm=2:length(mt),
    my(mm)=my(mm-1)+(dt/mtau)*(mamp*mu(mm)-my(mm-1));	%u(mm-1)???
  end;
  %my2=xshift2(my,mt0,1); my=my2(:);
  my2=tshift(mt,my,mt0,1); my=my2(:);
  %keyboard,
  if verb_flag, 
    disp(sprintf('  t0=%.3f, tau=%.3f, amp=%.3f',mt0,mtau,mamp)); 
    if nargin>5,
      figure(2), plot(mt,my,mt,mz),
    end;
  end;
  if nargin>5,
    my=my-mz;
  end;
return

