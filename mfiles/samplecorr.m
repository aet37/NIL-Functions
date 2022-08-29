function r=samplecorr(x,y)
% Usage ... r=samplecorr(x,y)

x=x(:);
y=y(:);

mx=mean(x);
my=mean(y);

nx=x-mx; ny=y-my;
num=sum(nx.*ny);
den=sqrt(sum(nx.*nx))*sqrt(sum(ny.*ny));

r=num/den;
