
clear all

% equivalent vessel dimmensions
Vc=1;			% cm^3
Lc=0.6;			% cm
Rc=Vc/sqrt(pi*L);	% cm
Ac=pi*Rc^2;

% vessel grid
dR=Rc/20;
RR=[-Rc:dR:Rc];

% flow
F=1;			% ml/s/100g
ubar=F/Ac;		% cm/s

% oxygen tension
Ppa=90;			% mmHg



% solve the equations -- easy plug into analytic form from Ying

rterm = (1 + (10/3)*(r.^2 - 0.25*r.^4));
twoA0 = Ct/C0 - (Ct/C0 - C0)*(1/(7/2 + rterm));

Dterm = (40*D)/(3*R0*ubar);
A1 = (Ct/Ct - C0) / ((7/2 + rterm)*exp(Dterm*(z-t)));

Cc = twoA0 + A1*rterm*exp(Dterm*(z-t));

dCcdr = A1*exp(Dterm*(z-t))*(10/3);

