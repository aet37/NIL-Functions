function y=msd_ttest(x,y,sx,sy,nx,ny,var_flag)
% Usage ... y=msd_ttest(x,y,sx,sy,nx,ny,var_flag)
%
% var_flag: 1=equal variances, 0=unequal variances (default)

if nargin<7, var_flag=0; end;

if length(x)>1, if exist('sx'), var_flag=sx; end; end;
if length(x)>1, sx=std(x(:)); nx=length(x(:)); x=mean(x(:)); end;
if length(y)>1, sy=std(y(:)); ny=length(y(:)); y=mean(y(:)); end;

if var_flag,
  % two distributions have the same variance
  s_xy = sqrt( (nx-1)*sx^2 + (ny-1)*sy^2 );
  s_xy = s_xy/sqrt( nx+ny-2 );
  t = (x - y)/(s_xy*sqrt(1/nx+1/ny));
  df = nx + ny - 2;
else,
  % two distributions, unequal variance
  s_xy = sqrt( sx^2/nx + sy^2/ny );
  t = (x - y)/s_xy;
  df = ((sx^2/nx + sy^2/ny)^2);
  df = df/( ((sx^2/nx)^2)/(nx-1) + ((sy^2/ny)^2)/(ny-1) );
end;
p = 2 * tcdf(-abs(t), df);

y=struct('t',t,'sd',s_xy,'df',df,'p',p);
%y.sd=s_xy;
%y.df=df;
%y.p=p;

if nargout==0,
  disp(sprintf('  t= %.2f  sd= %.2f  df= %.1f  p=%.3f',t,s_xy,df,p));
  clear y
end;
 
