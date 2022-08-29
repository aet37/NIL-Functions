function y=myvolinterp1(vol,scale,itype)
% Usage ... y=myvolinterp1(vol,scale,itype)
%
% scales for each dimension, less than 1 zooms up
% itype is interpolation method

if nargin<3, itype='linear'; end;
if length(scale)==1, scale=[1 1 1]*scale(1); end;

[xx,yy,zz]=meshgrid([1:size(vol,1)],[1:size(vol,2)],[1:size(vol,3)]);
[xi,yi,zi]=meshgrid([1:scale(1):size(vol,1)],[1:scale(2):size(vol,2)],[1:scale(3):size(vol,3)]);

y=interp3(xx,yy,zz,vol,xi,yi,zi,itype);


