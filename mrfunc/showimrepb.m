function [im,newmap]=showimrepb(im1,im2,bcolor)
% Usage ... [im,cmap]=showimrepb(im1,im2,bcolor)
%
% Image replace with different colors, similar to superposition
% but image2 is shown with a hot color palette of size fc with
% respect to the gray-scaled image1. image2 is assumed to have
% zeros where the values of image1 will be replaced

if (nargin<4), figno=1; end;
if (nargin<3), fc=0.2; end;

figure(figno)
clf

cmap=colormap;
gmap=mygraycmap(255);

if (nargin<3), bcolor=[1 .5 0]; end;

glen=length(gmap);

newmap=[gmap;bcolor];

rim1=max(max(im1))-min(min(im1));
rim2=max(max(im2))-min(min(im2));

uim1=(im1-min(min(im1)))./rim1; 
uim2=(im2-min(min(im2)))./rim2; 

sim1=round(glen*uim1)+1;
sim1min=min(min(sim1)); sim1max=max(max(sim1));

dim=256*im2.*(im2~=0)+sim1.*(im2==0);

colormap(newmap);
image(dim);
colormap(newmap);

if (nargout>0), im=dim; end;

