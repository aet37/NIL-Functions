function [f,g]=linc2(x,t,u,y)
% [f,g]=linc2(x,t,u,y)
% Minimizes the linear experiment at hand. This experiment
% looks at the input, convolves it with the first two terms
% of x (width and slope), and then passes it through a
% transfer function of type: as1+a2/b1s2+b2s+b3. The output
% is then subtracted from the original data y, then squared
% and divided by the standard deviation of each term. This
% way the chi-squared value is minimized.
% Note: that the input and output must carry the same scale!
%  Also there are two parameters in total to consider.
%  x(1)- slope, x(2)-width
%  In this model params of CONV ONLY are exposed.

tl=length(t);
ul=length(u);
[yr,yc]=size(y);

% Transfer Function Parameters
a1=3.8; a2=.2;
b1=4; b2=2; b3=.5;

% Ramp pulse construction
v=zeros(size(t));
v=mybell5(t,x(1),x(2),x(3));
ampl=x(3);

w=myconv(u,v);

% Calculate system response using mysol function,
%  assume zero initial conditions.
z=mysol([a1 a2],[b1 b2 b3],w,t);

% Calculate standard deviation on original data
if ( (yr==1)|(yc==1) ),
  if (yr==1), ystd=std(y'); else, ystd=std(y); end;
else,
  for n=1:length(y), ystd(n)=1; end;
end;

% Calculate chi-squared value
if (size(y)~=size(z)), z=z'; end;
chim=(y-z)./sqrt(length(y)*ystd);
chim=chim.^2;
chi=0; for n=1:length(chim), chi=chi+chim(n)*chim(n); end;

%disp(['chi-sq ',num2str(chi)]);
%disp(['x1= ',num2str(x(1))]);
%disp(['x2= ',num2str(x(2))]);

% Display
plot(t,u*(ampl/8),t,y,t,z,t,v*(ampl/8));
text(5,ampl*0.7,['x1= ',num2str(x(1))]);
text(5,ampl*0.8,['chi ',num2str(chi)]);

% Constraints -- parameters must be greater than zero.
g(1)=-x(1);
g(2)=-x(2);
g(3)=-x(3);

f=chim;