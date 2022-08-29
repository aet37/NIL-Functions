function f=lin2(x,t,u,y,plant,center,slope)
% f=lin2(x,t,u,y,plant,center,slope)
% Minimizes the linear experiment at hand. This experiment
% looks at the input, convolves it and then passes it through
% transfer function of type: as1+a2/b1s2+b2s+b3. The output
% is then subtracted from the original data y, then squared
% and divided by the standard deviation of each term. This
% way the chi-squared value is minimized.
% Note: that the input and output must carry the same scale!
%  Also there are two parameters in total to consider.
%  x(1)- width, x(2)- amp, x(3)- center x(4)- slope (if req)
%  In this model params of CONV ONLY are exposed.
%  Also, ALL DATA MUST BE IN COLUMNS

% Note: This program must have as convolving function a function
%  of at least three parameters.

t=t(:);
u=u(:);

tl=length(t);
ul=length(u);
[yr,yc]=size(y);

if ( exist('center')&(~exist('slope')) ),
  if (center) x(3)=center; end;
end;

if exist('slope'),
  if (center&slope), x(3)=slope; x(4)=center; end;
  if (center&~slope), x(4)=center; end; 
end;

% Transfer Function Parameters
%   a1=3.8; a2=.2;
%   b1=4; b2=2; b3=.5;
a1=plant(1);
a2=plant(2);
b1=plant(3);
b2=plant(4);
b3=plant(5);

% Exponential or Ramp spreading construction
v=zeros(size(t));
if exist('slope'),
  v=myramp(t,x(1),x(2),x(3),x(4));
else,
  v=mybell5(t,x(1),x(2),x(3));
end;
ampl=x(2);

w=myconv(u,v);
w=w(:);

% Calculate system response using mysol function,
%  assume zero initial conditions.
z=mysol([a1 a2],[b1 b2 b3],w,t);
z=z(:);

% Calculate standard deviation on original data
ystd=std(y');
if (length(ystd)==1),
  ystd=ones([length(y) 1]);
  y=y(:);
  ystd=ystd(:);
  ymax=max(y);
else,
  ymax=max(max(y));
  y=mean(y');
  y=y(:);
end;

% Calculate chi-squared value
chim=(y-z)./((length(y)*ystd).^(.5));
chi=0;
for n=1:length(chim), chi=chi+chim(n)*chim(n); end;

f=chim;

% Display output
plot(t,z,t,y,t,(u.*(ampl/8)),t,(v.*(ampl/8)));
text(5,ymax*.8,['x1= ',num2str(x(1))]);
text(5,ymax*.9,['chi ',num2str(chi)]);
