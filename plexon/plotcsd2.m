function plotcsd2(csd,range,lfp_scale,x_scale)
% Usage ... plotcsd2(csd_struct,crange,lfp_scale,x_scale)
%
% csd_struct from mycsd
% all other parameters are optional:
%  crange is the desired color range [min max]
%  lfp_scale is the scaling of the lfp data for overlay
%  -- 2nd entry of a cell indicates which plots to use


use_pcolor=1;
use_lfporig=1;

%figure(1), clf,
if iscell(csd),
  tmpavg=mean(csd{1}.csd(:,:,csd{2}),3);
  tmpcsd=csd{1}; tmpcsd.csd=tmpavg; clear csd
  csd=tmpcsd;
end;
if exist('range')==1, 
  if length(range)==3, ysc=range(3); else, ysc=1; end;
else,
  ysc=1;
end;
if length(size(csd.csd))==3,
  if use_pcolor,
    pcolor(csd.t,csd.d*ysc,mean(double(csd.csd),3)'),
  else,
    mesh(csd.t,csd.d,mean(csd.csd,3)'), view(2),
  end;
else,
  if use_pcolor,
    pcolor(csd.t,csd.d*ysc,double(csd.csd)'), 
  else,
    mesh(csd.t,csd.d,csd.csd'), view(2),
  end;
end;    
shading interp, axis tight,

%set(gca,'ydir','reverse');

minmax=get(gca,'clim');
title(sprintf('%e/%e',minmax(1),minmax(2)));

if exist('range','var'), if ~isempty(range),
  set(gca,'clim',[range(1) range(2)]);
  title(sprintf('%f/%f',range(1),range(2)));
end; end;

if exist('lfp_scale','var'), if ~isempty(lfp_scale),
  if use_lfporig,
    tmpt=csd.t_orig; tmplfp=csd.lfp_orig;
  else,
    tmpt=csd.t; tmplfp=csd.lfp;
  end;
  if length(size(tmplfp))==3, tmplfp=mean(tmplfp,3); end;
  tmplfpi=2:size(tmplfp,2)-1;
  if length(lfp_scale)==2, tmplfpi=lfp_scale{2}; lfp_scale=lfp_scale{1}; end;
  y=tmplfp(:,tmplfpi);
  y=y-ones(size(y,1),1)*mean(y,1);
  %y=y/max(max(abs(y(:))))*lfp_scale;
  y=y*lfp_scale;
  n=size(y,2);
  %figure (2), clf,
  hold on,
  for mm=1:n,
    %plot(tmpt,y(:,mm)+csd.d(mm+1),'k');
    plot(tmpt,y(:,mm)+csd.d(tmplfpi(mm)),'k');
    %plot(tmpt,y(:,mm)+csd.d(tmplfpi(mm)),'w');
  end;
  %plot([0 0],csd.d([1 end]),'k:'),
  hold off,
end; end;

if exist('x_scale'),
  set(gca,'XLim',x_scale);
end;

xlabel('Time (s)'), ylabel('Depth'), 
dofontsize(15); set(gca,'FontSize',12);

