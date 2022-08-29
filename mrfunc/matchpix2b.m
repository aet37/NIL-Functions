function [a,b]=matchpix2(pix1,pix2,l1,l2)
% Usage [a,b]=matchpix2(pix1,pix2,l1,l2)
%
% Similar to matchpix except that the inputs are
% different

[a1,b1]=matchpix(pix1(l1,:),pix2(l2,:));
tmppix1=pix1(a1,:);
tmppix2=pix2(b1,:);
a=matchpix(pix1,tmppix1);
b=matchpix(pix2,tmppix2);

