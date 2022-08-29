
clear all

x=[0:50];
xi=[0.4:1:50];

%y=cos(2*pi*x/20)+0.01*(x-20).^2+10;
%yi=cos(2*pi*xi/20)+0.01*(xi-20).^2+10;

y=gammafun(x,10)';
yi=gammafun(xi,10)';

yi2=sincinterp1(x,y,xi);
yi3=interp1(x,y,xi,'spline');
yi4=interp1(x,y,xi,'cubic');
yi5=interp1(x,y,xi);

e2=sum((yi-yi2).^2);
e3=sum((yi-yi3).^2);
e4=sum((yi-yi4).^2);
e5=sum((yi-yi5).^2);

disp(sprintf(' sinc= %f  spli= %f  cubi= %f  lin= %f',e2,e3,e4,e5));

[xi(10) x(9:12)],
xi(10)-x(9:12),
[yi(10) yi2(10) yi3(10) yi4(10) yi5(10)],
win1=0.54-0.46*cos(pi*(xi(10)-x(9:12)));
win2=0.5*(1+cos(pi*(xi(10)-x(9:12))));
w=sinc((xi(10)-x(9:12)));
yii=sum(w.*y(9:12)/sum(w));

