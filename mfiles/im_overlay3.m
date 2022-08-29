function [f,mycolors,myjet]=im_overlay(gim,rim,colors,gwl,fname)
% usage ... f=im_overlay(gray_im,label_im,[gray_minmaxHL],fname)

if nargin<3, colors=[]; end;

% make color table
ncolors=64;
nlabels=max(max(rim));

if (nargin<4), gwl=[]; end;
if isempty(gwl),
  gwl=[min(min(gim)) max(max(gim))];
end;

ngray=ncolors-nlabels;
mygray=[0:1/(ngray-1):1]'*[1 1 1];
if isempty(colors),
  fulljet=colormap('jet');
  iijet=floor(([1:nlabels]-0.5)*(size(fulljet,1)/nlabels))+1;
  myjet=fulljet(iijet,:);
else,
  myjet=colors;
end;
mycolors=[mygray;myjet];
%iijet,
%size(mycolors),

gim2=(gim-gwl(1))/(gwl(2)-gwl(1)); 
gim2(find(gim2<0))=0; 
gim2(find(gim2>1))=1;
if max(max(gim2))<0.99, gim2=gim2.*(1/max(max(gim2))); end;
gim2=round((ngray-1)*gim2)+1;
%show(high2'), pause,

rim2=(rim>0).*(rim+ngray);

f=gim2.*(abs(rim2)==0) + (abs(rim2)~=0).*rim2;
%[min(min(f)) max(max(f))],

colormap(mycolors),
image(f)
axis('image')
colormap(mycolors),

if nargin==5,
  qlty=90;
  imwrite(uint8(f),fname,'jpg','Quality',qlty)
end;

if (nargout==0)
  clear f
end;

