function [Cm,Ctot,Cp,h]=Cm(R,parms)
% Usage ... [Cm,Ctot,Cp]=Cm(R,[R0 h0 Rmax Rref Pi lambda])
%

R0=parms(1);
h0=parms(2);
Rmax=parms(3);
Rref=parms(4);
Pi=parms(5);
lambda=parms(6);


Etot = (1/2)*( (R/Rref).^2 - 1 );

h = vesselh(R,R0,h0);
href = vesselh(Rref,R0,h0);
hmax = vesselh(Rmax,R0,h0);

%h = -R + (R.^2 + 2*R0*h0 + h0^2 ).^(1/2) ;
%href = -Rref + (Rref.^2 + 2*R0*h0 + h0^2 ).^(1/2) ;
%hmax = -Rmax + (Rmax.^2 + 2*R0*h0 + h0^2 ).^(1/2) ;

Sp = (Pi*lambda*R0/h0)*(((Rmax*h0)/(lambda*hmax*R0)).^((R-R0)/(Rmax-R0)));
Spref = (Pi*lambda*R0/h0)*(((Rmax*h0)/(lambda*hmax*R0)).^((Rref-R0)/(Rmax-R0)));

Cp = Etot./(Sp - Spref);

Cm = Etot./( Pi*(R./h - Rref/href) - (Sp - Spref) );

Ctot = Cp.*Cm/(Cp + Cm);

if (nargout==0),
  plot(R,Cm)
end;

