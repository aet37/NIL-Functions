function y = fout_fun(v, parms)
% Usage ... f = fout_fun(v, parms)

form = 6; 	% usually 0 or 6

if (nargin < 2),
  alpha = 0.5;
  tauv = 0;
  dvdt = 0;
  beta = 0.1;
  gamma = 0.004;
  eta = 10;
  zeta = 0;
else,
  alpha = parms(1);
  tauv = parms(2);
  dvdt = parms(3);
  beta = parms(4);
  gamma = parms(5);
  eta = parms(6);
  zeta = parms(7);
  %if (length(parms)==8), form=parms(8); end;
end;

%histerises=0;
%if (~histerises), dvdt=1; end;

if (form == 1)
  % Traditional form I
  y = (v^(1/alpha)) + tauv*dvdt*(v^(-1/2));
elseif (form == 2),
  % Traditional form II
  y = (v^(1/alpha)) + tauv*dvdt*(v^(-1/2)) + beta*(v-1);
elseif (form == 3),
  % Linear form
  y = (v^(1/alpha));
elseif (form == 4),
  % Non-linear form
  if (tauv), if (dvdt<0), beta=0.05*beta; eta=0.95*eta; end; end;
  y = beta*(v-1) + gamma*(v^(1/eta));
  y = y + 1 - gamma;
elseif (form == 5),
  if dvdt<0, beta2=0; else, beta2=1; end;
  y=gamma*v^(1/eta) + tauv*dvdt*v^(-0.5) + zeta*v^(1/alpha) + beta2*beta*dvdt*(v-1);
  y=y+1-gamma-zeta;
elseif (form == 6),
  fp=beta;		% typically 0.7
  vp=(fp+1)^alpha;	% typically 0.4
  k=tauv; 		% typically 20
  y=((exp(k*(v-1))-1)/exp(k*(vp-1)))*fp+1;
else,
  % Mixed form ... default
  y = gamma*(v^(1/eta)) + tauv*dvdt*(v^(-1/2)) + zeta*v^(1/alpha) + beta*(v-1);
  y = y + 1 - (gamma+zeta);
end;

