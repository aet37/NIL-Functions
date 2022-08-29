function f=im_overlay(gim,rim,cf,fname)
% usage ... f=im_overlay(gray_im,red_im,[cf minmaxHL],fname)

if nargin<3, cf=1.0; end;

% make color table
ncolors=64;
if cf(1)==1,
  ngray=ncolors-1;
  nover=1;
  mygray=[0:1/62:1]'*[1 1 1];
  myhot=[1 .9 0];
else,
  ngray=round(cf(1)*ncolors);
  nover=ncolors-ngray;
  mygray=[0:1/(ngray-1):1]'*[1 1 1];
  othhot=colormap('hot');
  nhot=size(othhot,1);
  myhot=othhot(round([0:nover-1]*((nhot-1)/(nover-1))+1),:);
  %nextra=ncolors-round(0.95*ncolors);
  %myhot=othhot(round([1/nhot:1/(nover-nextra-1):.95]),:);
  size(mygray), size(myhot),
end;
mycolors=[mygray;myhot];
%size(mycolors),

if (length(cf)>1),
  gmax=cf(3);
  gmin=cf(2);
else,
  gmax=max(max(gim));
  gmin=min(min(gim));
end;
gim2=(gim-gmin)/(gmax-gmin); 
gim2(find(gim2<0))=0; 
gim2(find(gim2>1))=1;
if max(max(gim2))<0.99, gim2=gim2.*(1/max(max(gim2))); end;
gim2=round((ngray-1)*gim2)+1;
%show(high2'), pause,

rim2=rim;

if cf(1)==1,
  f=gim2.*(abs(rim2)==0) + ncolors*(abs(rim2)~=0);
else,
  if (length(cf)>3),
    rmin=cf(4);
    rmax=cf(5);
  else,
    rmax=max(max(rim2));
    rmin=min(min(rim2));
  end;
  rim3=(rim2-rmin)/(rmax-rmin);
  rim3(find(gim3<0))=0; 
  rim3(find(gim3>1))=1;
  rim3=round((nover-1)*rim2)+1+ngray;
  f=high2.*(abs(rim2)==0) + rim3.*(rim3~=0);
end;

if nargout==0,
  colormap(mycolors),
  image(f)
  axis('square')
end;

if nargin==4,
  qlty=90;
  imwrite(uint8(f),fname,'jpg','Quality',qlty)
end;

