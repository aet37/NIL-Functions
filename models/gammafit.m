function e=gammafit(x,t,y,tbias,b,s)
% Usage ... e=gammafit(x,t,y,tbias,b,s)

if nargin<6, s=zeros(size(y)); end;
if nargin<5, b=8.6; end;
if nargin<4, tbias=[1 length(t)]; end;

tau=x(1);
b=x(2);
amp=x(3);
del=x(4);

yf=gammafun(t,del,tau,b,amp);
%er=sqrt((y-yf).*(y-yf));
er=(y-yf);
e=er(tbias(1):tbias(2));

disp(sprintf('  tau=%.2f, b=%.2f, amp=%.2f, t0=%.2f',x(1),x(2),x(3),x(4)));
%disp(['tau= ',num2str(x(1),6),' amp= ',num2str(x(2),6),' del= ',num2str(x(3),6)]);

if nargout==0, plot(t,yf,t,y), end;

