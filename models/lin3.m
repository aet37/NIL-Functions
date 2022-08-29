function f=lin3(x,t,u,kind,normal,parms,order,y)
% f=lin3(x,t,u,kind,normal,parms,order,y)
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

% Spreading or broadening construction
v=zeros(size(t));
if (kind=='r'),
  v=myramp(t,parms(1),parms(2),parms(3),parms(4));
elseif (kind=='p'),
  v=mypulse(t,parms(1),parms(2),parms(3)); 
else,
  v=mybell5(t,parms(1),parms(2),parms(3));
end;

str='- ';
if (normal),
  str=[str,'Normalized'];
  nv=trapz(t,v);
  v=parms(2).*(v./nv);
end;

w=myconv(u,v);
w=w(:);

% Calculate system response using mysol function,
%  assume zero initial conditions.
gain=x(1);
zeros=[x(2:1+order(1))];
poles=[x(order(1)+2:1+order(1)+order(2))];
%num=gain.*[1 -zeros(1)];
%den=gain.*conv([1 -poles(1)],[1 -poles(2)]);
disp([str,' : z=',num2str(zeros,2),' , p=',num2str(poles,2)]);
z=mysol(gain.*[1 zeros(1)],[1 poles(1) poles(2)],w,t);
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
chim=(y-z)./((length(y)*ystd).^(.5));
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
