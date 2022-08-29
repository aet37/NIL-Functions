function [yy,lss]=getImLineProj(data,locPairs,parms)
% Usage ... [y,lss]=getImLineProj(data,locPairs,parms)
%
% data is a 3D variable, locPairs=[x1 y1; x2 y2; ...]
% parms=[nPixLine tSmooth]

if ischar(locPairs), if strcmp(locPairs,'select'),
  tmpim=mean(data,3);
  figure(1), clf,
  show(tmpim),
  tmpok=0;
  tmploc=[];
  while(~tmpok),
    disp('  select two locations for a line...');
    [tmpy0,tmpx0]=ginput(2);
    tmpy0=round(tmpy0);
    tmpx0=round(tmpx0);
    tmpmask=zeros(size(tmpim));
    tmpmask(tmpx0,tmpy0)=1;
    show(im_super(tmpim,tmpmask,0.4)), drawnow,
    tmpin=input('  locations ok? [0=no+repeat, 1=yes+another, 9/enter=yes+done]: ');
    if isempty(tmpin), tmpin=9; end;
    if ischar(tmpin), tmpin=num2str(tmpin); end;
    if tmpin==9,
      tmploc=[tmploc; tmpx0 tmpy0];
      tmpok=1;
    elseif tmpin==1,
      tmploc=[tmploc; tmpx0 tmpy0];
    end;
  end;
  locPairs=tmploc;
end;

for mm=1:floor(size(locPairs,1)/2),
  lss(mm).ny=4;
  lss(mm).aloc=mean(locPairs([1:2]+(mm-1)*2,:);
  lss(mm).dloc=diff(locPairs([1:2]+(mm-1)*2,:);
  lss(mm).dd=sqrt(sum(lss.dloc.^2));
  lss(mm).dang=atan(lss.dloc(2)/lss.dloc(1))*(180/pi);
  lss(mm).rw=[ny ceil(lss(mm).dd)];
end;

for mm=1:size(data,3),
  tmpim=data(:,:,mm);
  for nn=1:length(lss),
    [tmp1,tmpmsk1]=getRectImGrid(im,lss(nn));
    yy{nn}(:,mm)=mean(tmp1,2)';
  end;
end;

