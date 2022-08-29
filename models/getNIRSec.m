function [y,plen]=getNIRSec(lam,type,src)
% Usage ... [y,plen]=getNIRSec(lambda,type,src)
%
% lambda is wavelength(s) in nm
% type is 'hbo' or 'hbr'
% src is 1_or_'web' (default) or 2_or_'lab'

if nargin<3, src=[]; end;
if isempty(src), src=3; end;
if ischar(src),
  if strcmp(src,'lab'), 
      src=2; 
  elseif strcmp(src,'ma'),
      src=3;
  else, 
      src=1; 
  end;
end;

% Pathlength factor from Dunn et al Neuroimage 2005 paper
tmpx_Da=[490  530  560  570 580  590 600  610  620  630];
tmpy_Da=[0.56 0.57 0.52 0.5 0.49 0.9 1.58 2.04 2.50 2.87]; % OD(mm)

% Ma2016 data
if nargin==0,
  load NIRS_extData
  figure(1), clf,
  plot(lambda,[eHbO2 eHb])  
  axis tight, grid on, set(gca,'FontSize',14),
  xlabel('Wavelength (nm)'), ylabel('1/(cm M)'), dofontsize(17);
  fatlines(1.5); set(gca,'XLim',[450 700]);
  figure(2), clf,
  plot(tmpx_Da,tmpy_Da,'o-'),
  axis tight, grid on, set(gca,'FontSize',14),
  xlabel('Wavelength (nm)'), ylabel('OD (mm)'), dofontsize(17);
  fatlines(1.5);
  figure(3), clf,
  plot(lambda,[eHb./eHbO2]),
  axis tight, grid on, set(gca,'FontSize',14),
  xlabel('Wavelength (nm)'), ylabel('EC Ratio HbR/HbO'), dofontsize(17);
  fatlines(1.5); set(gca,'XLim',[450 700]);
  return;
end;


if src==2,
  disp('  using lab data');
  load hb_spectra
  lambda=hb.nm;
  eHb=0.1*hb.hbr;
  eHbO2=0.1*hb.hbo;
elseif src==3,
  load NIRS_extData
  load ma2016_data
  lambda=ma_data(:,1);
  eHb=0.1*ma_data(:,3);
  eHbO2=0.1*ma_data(:,2);
else,
  % from web and same as that used in Dunn et al Neuroimage 2005
  load NIRS_extData
  load ma2016_data
end;

% units: 1/(cm M) * 1cm/10mm ... (1/cm)/M or (1/cm)/(moles/L) or cm^-1/M
for mm=1:length(lam),
  if (strcmp(type,'hbr')|strcmp(type,'dhb')|strcmp(type,'dHb')|strcmp(type,'Hbr')|strcmp(type,'HbR')),
    y(mm)=interp1(lambda,eHb,lam(mm));
  else,
    y(mm)=interp1(lambda,eHbO2,lam(mm));
  end;
  if src==3,
    plen(mm)=interp1(ma_data_plen(:,1),ma_data_plen(:,2),lam(mm));    
  else,
  if (lam(mm)>=tmpx_Da(1))&(lam(mm)<=tmpx_Da(end)),
    plen(mm)=interp1(tmpx_Da,tmpy_Da,lam(mm));
  else,
    plen(mm)=nan;
  end;
  end;
end;

