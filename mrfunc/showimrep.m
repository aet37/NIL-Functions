function [im,newmap]=showimrep(im1,im2,fc,figno)
% Usage ... [im,cmap]=showimrep(im1,im2,fc,figno)
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
hmap=myhotcmap(256);
gmap=mygraycmap(256);

if (length(gmap)~=length(hmap)),
  warning('Gray and Hot colormaps are not the same size!');
end;

glen=length(gmap);

i1=round([1:1/(1-fc):glen]);
i2=round([1:1/fc:glen-(2/fc)]);
li1=length(i1);
li2=length(i2);

if ((li1+li2)<glen), i1=[i1 [li1+li2+1:glen] ]; end;

newmap=[gmap(i1,:);hmap(i2,:)];

rim1=max(max(im1))-min(min(im1));
rim2=max(max(im2))-min(min(im2));

uim1=(im1-min(min(im1)))./rim1; 
uim2=(im2-min(min(im2)))./rim2; 

sim1=round((1-fc)*glen*uim1)+1;
sim2=round(fc*glen*uim2)+1 + ceil((1-fc)*glen)+1;

sim1min=min(min(sim1)); sim1max=max(max(sim1));
sim2min=min(min(sim2)); sim2max=max(max(sim2));
sim2a=sim2min+(glen-sim2min).*(sim2-sim2min)./(sim2max-sim2min);
%min(min(sim1)), max(max(sim1)),
%min(min(sim2a)), max(max(sim2a)),

dim=sim2a.*(im2~=0)+sim1.*(im2==0);

colormap(newmap);
image(dim);
colormap(newmap);

if (nargout>0), im=dim; end;

