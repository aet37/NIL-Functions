function f=lin21x(x,t,tbias,u,kind,normal,order,y,f1,f2)
% f=lin21x(x,t,tbias,u,kind,normal,order,y,f1,f2)
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

% Spreading or broadening construction
v=zeros(size(t));
xlen=0;
if (kind=='r'),
  str=['Ramp '];
  if (exist('f1')&~exist('f2')), v=myramp(t,x(1),x(2),x(3),f1); str=[str,' f1'];
  elseif (exist('f1')&exist('f2')),
    if (f1~=0), v=myramp(t,x(1),x(2),f1,f2); str=[str,' f1 f2'];
    else, v=myramp(t,x(1),x(2),f2,x(3)); str=[str,' f2'];
    end;
  else, v=myramp(t,x(1),x(2),x(3),x(4)); str=[str,' All args'];
  end;
  xlen=4;
elseif (kind=='p'),
  str=['Pulse '];
  if exist('f1'), v=mypulse(t,x(1),x(2),f1); str=[str,' f1']; 
  else, v=mypulse(t,x(1),x(2),x(3)); str=[str,' All args'];
  end;
  xlen=3;
else,
  str=['Bell5 '];
  if exist('f1'), v=mybell5(t,x(1),x(2),f1); str=[str,' f1'];
  else, v=mybell5(t,x(1),x(2),x(3)); str=[str,' All args'];
  end;
  xlen=3;
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
zeros=[x(xlen+1:xlen+order(1))];
poles=[x(xlen+order(1)+1:xlen+order(1)+order(2))];
disp([str,'  : z=',num2str(zeros,2),', p=',num2str(poles,2)]);
%num=[1 -zeros(1)];
%den=conv([1 -poles(1)],[1 -poles(2)]);
z=mysol([1 zeros(1)],[1 poles(1) poles(2)],w,t);
z=z(:);

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
else,
  chim=(y-z)./((length(y)*ystd).^(.5));
end;

% chim=(y-z)./((length(y)*ystd).^(.5));
chi=0;
for n=1:length(chim), chi=chi+chim(n)*chim(n); end;

f=chim;

% Display output
%subplot(2,1,1);
plot(t,z,t,y);
text(5,ymax*.8,['x1= ',num2str(x(1))]);
text(5,ymax*.9,['chi ',num2str(chi)]);
%subplot(2,1,2);
%plot(t,u,t,v,t,w);
