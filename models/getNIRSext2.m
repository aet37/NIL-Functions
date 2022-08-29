function [y,plen]=getNIRSext2(lam)
% Usage ... [y,plen]=getNIRSext2(lambda)
%
% returns the extinction coefficients of oxy-hemoglobin and deoxy-hemoglobin 
% at wavelengths lambda (row-ordered [HbO HbR]). If a second output argument is provided  
% then the pathlength at those wavelengths are also provided. All values are
% interpolated from the table values provided in Ma2016 (Hillman Lab).
%
% Ex. [ec,pd]=getNIRSext2([570 620]);
%     [ec572,pd572]=getNIRSext2(572+[-4:4]);
%     getNIRSext2

load ma2016_data

lambda=ma_data(:,1);
ecHbO=ma_data(:,2);
ecHbR=ma_data(:,3);

lambdax=ma_data_plen(:,1);
plenx=ma_data_plen(:,2);


% if no arguments at all then plot the tables
if nargin==0,
  figure(1), clf,
  subplot(311), plot(lambda,[ecHbO ecHbR],'LineWidth',1.5)  
  axis tight, grid on, legend('HbO','HbR'), 
  xlabel('Wavelength (nm)'), ylabel('Ext Coeff 1/(cm M)'), 
  set(gca,'XLim',[450 700]);
  subplot(312), plot(lambdax,plenx,'LineWidth',1.5),
  axis tight, grid on, 
  xlabel('Wavelength (nm)'), ylabel('Est Avg Pathlength X (mm)'), 
  subplot(313), plot(lambda,ecHbR./ecHbO,'LineWidth',1.5),
  axis tight, grid on, 
  xlabel('Wavelength (nm)'), ylabel('EC Ratio HbR/HbO'), 
  set(gca,'XLim',[450 700]);
  return;
end;


% switch to mm
eHb=0.1*ecHbR;
eHbO2=0.1*ecHbO;


% units: 1/(cm M) * 1cm/10mm ... (1/cm)/M or (1/cm)/(moles/L) or cm^-1/M
for mm=1:length(lam),
  y(mm,1)=interp1(lambda,eHbO2,lam(mm));
  y(mm,2)=interp1(lambda,eHb,lam(mm));
  plen(mm)=interp1(lambdax,plenx,lam(mm));    
end;


