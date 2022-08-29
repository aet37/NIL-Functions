function f=impolyfit(im,n)
% Usage ... p=impolyfit(im,n)
%
% pp=parameters xg=x-grid yg=y-grid im=image(data) n=order
% for now n=2

[xg,yg]=meshgrid([1:size(im,1)],[1:size(im,2)]);
x0=[size(im,1)/2 size(im,2)/2 0 0 0 0 0];
xu=
xl=

xx=nonlinlsq(@impolyeval,




function [ee,zz]=impolyeval(xx,xg,yg,im,n)
xg=xg-xx(1);
yg=yg-xx(2);

zz=zeros(size(im));
zz=zz+xx(3)*xg;
zz=zz+xx(4)*(xg.^2);
zz=zz+xx(5)*yg;
zz=zz+xx(6)*(yg.^2);
zz=zz+xx(7)*(xg.*yg);

ee=zz-im;
end

