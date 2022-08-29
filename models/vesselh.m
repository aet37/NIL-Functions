function h=vesselh(r,r0,h0)
% Usage ... h=vesselh(r,r0,h0)


h = -r + sqrt(r.*r + 2*r0.*h0 + h0.*h0);

