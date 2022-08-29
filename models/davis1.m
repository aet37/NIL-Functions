function ydot=davis1(t,y)
% Simulation of Davis model as indicated in his
% abstract.

% Initial conditions [0 0 .6]

% Activation parameters dependent on time
tact=[4 20];
if ( (t>=tact(1))&(t<tact(2)) ),
   % Activation
   F=1.7*56;		% ml blood/min/100g on activation increase 70 percent
   CMRO2=1.2*4.2;	% ml o2/min/100g on activation increase 20 percent
else,
   % Non-activating
   F=56;
   CMRO2=4.2;
end;

% Steady-state Parameters
E=.5;		% unidirectional extraction coefficient
a=50;		% ratio of O2 solubility blood to tissue
Vc=.02;		%  2 percent capillary volume
Vv=.02;		%  2 percent venous outflow volume
Vt=.96;		% 96 percent tissue volume
PS=-F*log(1-E);	% Resistance to diffusion of O2 from blood to tissue

Ca=.97;

x=1;		% Distance
Ccdx= (CMRO2/(F*E))*(PS/(a*F))*exp(-PS*x/(a*F));
Ccx1= Ca -(CMRO2/(F*E))*( 1 -exp(-PS*x/(a*F)) );

% Description of parameters (O2 concentration in compartments)
% y(1) = Cc
% y(2) = Ct
% y(3) = Cv

ydot(1)= (1/Vc)*( -F*Ccdx -(PS/a)*( y(1) -a*y(2) ) );
ydot(2)= (1/Vt)*( (PS/a)*( y(1) -a*y(2) ) -CMRO2 );
ydot(3)= (1/Vv)*( -F*( y(3) -y(1) ) );
