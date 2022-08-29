function plotcsdstyle(data,tt,dd,range,data_scale,x_scale)
% Usage ... plotcsdstyle(data,tt,dd,range,data_scale,x_scale)


use_pcolor=1;
use_bar=1;

%figure(1), clf,

if exist('range')==1, 
  if length(range)==3, dsc=range(3); else, dsc=1; end;
else,
  dsc=1;
end;

if use_pcolor,
  pcolor(tt,dd*dsc,data'),
else,
  mesh(tt,dd*dsc,data'), view(2),
end;
shading interp, axis tight,

%set(gca,'ydir','reverse');

minmax=get(gca,'clim');
title(sprintf('%e/%e',minmax(1),minmax(2)));

if exist('range','var'), if ~isempty(range),
  set(gca,'clim',[range(1) range(2)]);
  title(sprintf('%f/%f',range(1),range(2)));
end; end;

if exist('data_scale','var'), if ~isempty(data_scale),
  y=data(:,2:end-1);
  y=y-ones(size(y,1),1)*mean(y,1);
  %y=y/max(max(abs(y(:))))*lfp_scale;
  y=y*data_scale;
  n=size(y,2);
  %figure (2), clf,
  hold on,
  for mm=1:n,
    plot(tt,y(:,mm)+dd(mm+1),'k');
  end;
  %plot([0 0],csd.d([1 end]),'k:'),
  hold off,
end; end;

if exist('x_scale'),
  set(gca,'XLim',x_scale);
end;

if use_bar,
  colorbar,
end;


