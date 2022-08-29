function f=im_overlay(highim,lowim,cf,fname)
% usage ... f=im_overlay(highim,lowim,[cf minmaxHL],fname)

if nargin<3, cf=0.9; end;

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
  highmax=cf(3);
  highmin=cf(2);
else,
  highmax=max(max(highim));
  highmin=min(min(highim));
end;
high2=(highim-highmin)/(highmax-highmin); 
high2(find(high2<0))=0; 
high2(find(high2>1))=1;
if max(max(high2))<0.99, high2=high2.*(1/max(max(high2))); end;
high2=round((ngray-1)*high2)+1;
%show(high2'), pause,


if (size(highim,1)==(size(lowim,1)/4)),
  low2=zoomup4(lowim);
elseif (size(highim,1)==(size(lowim,1)/2)),
  low2=zoomup2(lowim);
else,
  low2=lowim;
end;
 
if cf(1)==1,
  f=high2.*(abs(low2)==0) + ncolors*(abs(low2)~=0);
else,
  if (length(cf)>3),
    lowmin=cf(4);
    lowmax=cf(5);
  else,
    lowmax=max(max(low2));
    lowmin=min(min(low2));
  end;
  low3=(low2-lowmin)/(lowmax-lowmin);
  low3=round((nover-1)*low2)+1+ngray;
  f=high2.*(abs(low2)==0) + low3.*(low3~=0);
end;

if nargout==0,
  colormap(mycolors),
  image(f')
  axis('square')
end;

if nargin==4,
  qlty=90;
  imwrite(uint8(f),fname,'jpg','Quality',qlty)
end;

