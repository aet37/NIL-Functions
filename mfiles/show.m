function [out,cmap] = show(a,windfact,ncolors,jname)
% usage .. show(a,f,ncolors,jname)
% displays matrix "a" as a greyscale image in the matlab window
% and "f" is the optional window factors [min,max]

verbose_flag=0;
title_flag=1;

if ischar(a),
  if strcmp(a(end),'/'),
    tmpd=dir([a,'*0001.*']);
    if isempty(tmpd), tmpd=dir([a,'*.tif']); end;
    if isempty(tmpd), error('  no file found under given directory'); end;
    for mm=1:length(tmpd),
      b(:,:,mm)=double(imread([a,tmpd(mm).name]));
    end;
    a=b;
  else,
    a=readOIS3(a);
  end;
end;

if ~exist('ncolors','var'), ncolors=[]; end;
if isempty(ncolors), ncolors=128; end;

if nargin<2, windfact=[]; end;

if isempty(windfact),
  amin = min(a(:));
  amax = max(a(:));
  minmax = [amin,amax];
  a = (a  - amin);
else
  if iscell(windfact),
    for mm=1:length(windfact),
      amin(mm)=windfact{mm}(1);
      amax(mm)=windfact{mm}(2);
      a(:,:,mm)=a(:,:,mm)-amin(mm);
      a(:,:,mm)=a(:,:,mm)/(amax(mm)-amin(mm));
    end
    minmax=[mean(amin) mean(amax)];
  else,
    amin = windfact(1);
    amax = windfact(2);
    minmax = windfact;
    a = (a  - amin);
    a = a .* (a > 0);
  end
end

if size(a,3)==1,
  cmap=[0:1/(ncolors-1):1]'; cmap=[cmap cmap cmap];

  colormap(cmap);
  imout=(a)./(amax-amin).*ncolors;
  imout2=round(imout);
  image(imout);
  axis('image');
  axis('on');
  grid on;

  if exist('jname','var'),
      disp(sprintf('  writing jpeg %s ...',jname));
      imwrite(imwlevel(imout,[0 ncolors],1),jname,'JPEG','Quality',100)
  end

else,
  if size(a,3)>3,
    a=a(:,:,1:3);
  elseif size(a,3)==2,
    a(:,:,3)=0;
  end;
  if ~iscell(windfact),
    imout=a/(amax-amin);
  else,
    imout=a;
  end
  
  image(imout), axis('image'),
  
  if exist('jname','var'),
      disp(sprintf('  writing jpeg %s ...',jname));
      imwrite(imwlevel(imout,[0 1],0),jname,'JPEG','Quality',100)
  end
end;

if nargout==0,
  if verbose_flag,
    disp(['min/max= ',num2str(minmax(1)),' / ',num2str(minmax(2))]);
  end;
  if (title_flag), title(sprintf('min/max = %f/%f',minmax(1),minmax(2))); end;
else,
  out=imout;
end;
