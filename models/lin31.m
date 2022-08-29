function [f,z]=lin21(x,t,tbias,u,kind,normal,num,den,tauu,ampu,y,f1,f2)
% f=lin21(x,t,tbias,u,kind,normal,num,den,tauu,ampu,y,f1,f2)
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

% Transfer Function Parameters
%   a1=3.8; a2=.2;
%   b1=4; b2=2; b3=.5;

% Filtering function initialization and selection
v=0;
if (kind=='r'),
  str=['Ramp '];
  if (exist('f1')&~exist('f2')), v=myramp(t,x(1),x(2),x(3),f1); str=[str,' f1'];
  elseif (exist('f1')&exist('f2')),
    if (f1~=0), v=myramp(t,x(1),x(2),f1,f2); str=[str,' f1 f2'];
    else, v=myramp(t,x(1),x(2),f2,x(3)); str=[str,' f2'];
    end;
  else, v=myramp(t,x(1),x(2),x(3),x(4)); str=[str,' All args'];
  end;
elseif (kind=='p'),
  str=['Pulse '];
  %if exist('f1'),
  %  v=mypulse(t,x(1),x(2),f1); str=[str,' f1']; 
  %else,
    v=mypulse(t,x(1),x(2),x(3)); str=[str,' All args'];
  %end;
else,
  str=['Bell5 '];
  %if exist('f1'),
  %  v=mybell5(t,x(1),x(2),f1); str=[str,' f1'];
  %else,
    v=mybell5(t,x(1),x(2),x(3)); str=[str,' All args'];
  %end;
end;

if (normal),
  str=[str,' normalized'];
  nv=trapz(t,v);
  v=x(2).*(v./nv);
end;

w=myconv(u,v);
w=w(:);

% Calculate system response using mysol function,
%  assume zero initial conditions.
z=mysol(num,den,w,t);
z=z(:);

numu=[1];
denu=conv([1 tauu],[1 tauu]);
wu=zeros(size(t));
flag1=0;
for m=1:length(wu),
  if (u(m)~=0)&(~flag1),
    wu(m)=1;
    flag1=1;
  end;
  if (u(m)==0)&(flag1),
    flag1=0;
  end;
end;
zu=mysol(numu,denu,wu,t);
zu=zu*ampu;

z=z+zu;

%plot(t,z,t,zu)
%pause,

if exist('f1'),
  f1=f1(:);
  str=[str,' - super'];
  z=z+f1;
end;

% Calculate standard deviation on original data
%ystd=std(y');
%if (length(ystd)==1),
  ystd=ones([length(y) 1]);
  y=y(:);
  ystd=ystd(:);
  ymax=max(y);
%else,
%  ymax=max(max(y));
%  y=mean(y');
%  y=y(:);
%end;

% Calculate chi-squared value
if (tbias),
  str=[str,' - Biased'];
  if length(tbias)==1,
    a=tbias(1); b=length(y);
  elseif length(tbias)==2,
    a=tbias(1); b=tbias(2);
  else,
    a=1; b=length(y);
  end;
  chim=( y(a:b)-z(a:b) )./( ((b-a)*ystd(a:b)).^(.5) );
  str=[str,' (',int2str(length(chim)),')'];
else,
  chim=(y-z)./((length(y)*ystd).^(.5));
end;

chi=0;
for n=1:length(chim), chi=chi+chim(n)*chim(n); end;
f=chim;

str=[str,' - ',num2str(chi,6),',',num2str(x(1),3),',',num2str(x(2),3),',',num2str(x(3),3)];
disp(str);

% Display output
%subplot(2,1,1);
plot(t,z,t,y);
text(5,ymax*.8,['x1= ',num2str(x(1))]);
text(5,ymax*.9,['chi ',num2str(chi)]);
%subplot(2,1,2);
%plot(t,u,t,v,t,w);
