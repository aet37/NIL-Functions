function y=fellik(xr,yr,xc,yc,maj,min,ang,val)
% function y=ellik(xr,yr,esz,xc,yc,maj,min,ang,val)
%   generates k-space for an ellipse
%  xr,yr = k-space coordinates (critical sampling inteval = 1)
%    the following coord are given in units of fractions of FOV (-0.5,0.5)
%  xc,yc = center coords
%  maj,min = major and minor (x and y) radii
%  ang = rotation of major axis from x-axis (of ellipse)
%  val = value of FTed ellipse

i = sqrt(-1);
if ang == 0
  in = abs(xr.*maj + i.*yr.*min);
else
  ang = ang/180*pi;
  in = abs((xr.*cos(ang) + yr.*sin(ang)).*(maj) + i.*(yr.*cos(ang) - xr.*sin(ang)).*(min));
end
%ks =bessel(1,(2.*pi.*(in+eps))) ./ (in+eps);
ks =besselj(1,(2.*pi.*(in+eps))) ./ (in+eps);
y = ks .* exp(-(2*pi*i).*(-xc.*xr + yc.*yr)).*val;


