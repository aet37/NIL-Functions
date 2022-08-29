function [o2mmcurrfit,o2mm,o2mmfit]=po2cal(o2,o2curr,p_atm,p_wvapor)
% Usage ... [o2mmcurrfit,o2mm]=po2cal(o2,o2curr,p_atm,p_wvapor)

% should account for probe solution vs. medium solution (K)
% also for temperature differences and water vapor pressure in solution

%clear all

%o2=[0 20.8 100];
%o2curr=[0.082 0.347 1.256];

o2fit=polyfit(o2,o2curr,1);

if (~exist('p_atm')),
  p_atm=761;
end;
if (~exist('p_wvapor')),
  p_wvapor=47;
end;

o2mm=o2*((p_atm-p_wvapor)/100);
o2mmfit=polyfit(o2mm,o2curr,1);

o2mmcurrfit=polyval(o2mmfit,o2mm);

o2_des=[25 40 60 75];
po2_des=interp1(o2mm,o2mmcurrfit,o2_des);

if (nargout==0),
plot(o2mm,o2curr,o2mm,o2mmcurrfit)
xlabel('PO2'), ylabel('O2 Current'),

[o2_des(:) po2_des(:)],
end;

