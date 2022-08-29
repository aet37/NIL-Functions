function y=r2_so2(r2,adj_flag)
% Usage ... y=r2_so2(r2,adj_flag)
%
% R2 values are for 9.4T


so2=[0.1:0.01:1.0];
calc_r2=478-458*x;		% from Sang-Pil Lee's 1999 MRM paper

if adjust_flag,
  po2=[0.1:0.01:500];
  % should really be using Severinghaus equation here
  so2_26=1./(1+(26./po2).^hill);
  so2_38=1./(1+(38./po2).^hill);
  
  y_po2=interp1(so2_26,po2,so2);
  % corrected values are now new_so2, calc_r2
  new_so2=interp1(po2,so2_38,y_po2);
else,
  new_so2=so2;  
end;

y=interp1(calc_r2,new_so2,r2);


