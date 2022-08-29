
clear all

Y=[0:0.1:1.0];
b=[0:0.002:0.05];

hct=0.4;
dX0=0.18e-6;
w0=42.7e6*3.0;

nu = dX0*(1-Y)*hct*w0;

for mm=1:length(b),
  r2starA(mm,:) = 4.3*nu*b(mm);
  r2starB(mm,:) = 0.04*(nu.^2)*b(mm);
  r2starC(mm,:) = 0.70*(nu.^1.5)*b(mm);
end;

