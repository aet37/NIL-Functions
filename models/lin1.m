function f=lin1(x,t,u,y)
% f=lin1(x,t,u,y)
% Minimizes the linear experiment at hand. This experiment
% looks at the input, convolves it with the first two terms
% of x (width and slope), and then passes it through a
% transfer function of type: as1+a2/b1s2+b2s+b3. The output
% is then subtracted from the original data y, then squared
% and divided by the standard deviation of each term. This
% way the chi-squared value is minimized.
% Note: that the input and output must carry the same scale!
%  Also there are seven parameters in total to consider.
%  x(1)- slope, x(2)-width, x(3)- a1, x(4)-a2, x(5)-b1, ...
%  In this model all params of conv and tf are exposed.

tl=length(t);
ul=length(u);
[yr,yc]=size(y);

% Ramp pulse construction
v=zeros(size(t));
tw=0.5/x(1);
for n=1:tl,
  if ( t(n)<=2*tw ), v(n)=x(1)*t(n); end;
  if ( (t(n)>=(2*tw))&(t(n)<=(x(2)+tw)) ), v(n)=1;
  else, v(n)= -x(1)*(t(n)-(x(2)+tw))+1; end;
  if ( v(n)<0 ), v(n)=0; end;
end;

% Convolution of input with ramped pulse
tmpw=conv(u,v);

% Eliminate extra zeros from convolution
for n=1:tl, w(n)=tmpw(n); end;

% Calculate system response using mysol function,
%  assume zero initial conditions.
[z,x]=mysol([x(3) x(4)],[x(5) x(6) x(7)],w,t);

% Calculate standard deviation on original data
if ( (yr==1)|(yc==1) ),
  if (yr==1), ystd=std(y'); else, ystd=std(y); end;
else,
  for n=1:length(y), ystd(n)=1; end;
end;

% Calculate chi-squared value
chi=((abs(y-z).^2)./ystd);

f=chi;