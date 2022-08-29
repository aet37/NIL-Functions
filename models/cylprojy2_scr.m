
clear all
close all

a=[1:1000];
b=[1:1000];

a=a/1000-0.5;
b=b/1000-0.5;
c=zeros(1000,1000);
z1=zeros(1000,1000);
z2=zeros(1000,1000);

r1=0.35; c1=10;
r2=0.30; c2=-6;

y1=0.0; y1w=0.05;
y2=-0.2; y2w=0.05;

for mm=1:1000, for nn=1:1000,
  if sqrt(a(mm)^2+b(nn)^2)<r1, c(mm,nn)=c(mm,nn)+c1; end;
  if sqrt(a(mm)^2+b(nn)^2)<r2, c(mm,nn)=c(mm,nn)+c2; end;
  z1(mm,nn)=exp(-(a(mm)-y1)^2/y1w);
  z2(mm,nn)=exp(-(a(mm)-y2)^2/y2w);
end; end;

d=mean(c,2);

cs=im_smooth(c,2);
ds=mean(cs,2);

figure(1), clf,
%subplot(221), show(c), 
subplot(211), show(cs), 
%subplot(223), plot(d), axis tight,
subplot(212), plot(ds), axis tight,

yy1=2*sqrt(1-(a.*a)./(r1*r1));
yy1(find(abs(a)>r1))=0;
yy2=2*sqrt(1-(a.*a)./(r2*r2));
yy2(find(abs(a)>r2))=0;

