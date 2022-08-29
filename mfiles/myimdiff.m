function [y,xd1,xd2]=myimdiff(x)
% Usage ... y=myimdiff(x)

xd1=diff(x);
xd2=diff(x.').';

xd1=[zeros(1,size(x,2));xd1];
xd2=[zeros(size(x,1),1) xd2];

% definitely lazy edge detection here
ym=(xd1.^2 + xd2.^2).^(0.5);
ya=tanh(xd2./xd1);

y=ym.*exp(j*ya);

y(find(isnan(y)))=0;

