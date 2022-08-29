
% dynamic simulation of Valabregue compartmental oxygen delivery model
% as appears in JCBFM 23:536 (2003)


clear all

F0=50;
PS=3000;
Pt=0;
Pa0=90;

fstart=10/60;
fdur=20/60;
framp=2/60;
f_dt=1/60;
dF=0.5;
dCMRO2=0.25;

% general simulation variables
%  select x and t to be of
%  the same length for now

opt1min=optimset('fminbnd');

L=200e-4;	% units: cm
dx=L/100;
x=[0:dx:L];	% units: cm

T=60/60;	% units: min
dt=0.6/60;
t=[0:dt:T];	% units: min

alpha=1.39e-3;	% units: mmol/L/mmHg
hill=2.73;
P50=26;		% units: mmHg
PO=4;
cHb=2.3;	% units: mmol/L

CMRO20=4.56*(1000/22400);	% units: (mL/min/100g)*(1000mmol/22400mL)
Km=0.1*alpha;	% units: mmHg 

Vt=96*(1/1000);	% units: mL/100g
Vc=1*(1/1000);	% units: mL/100g


% use the steady-state solution as the initial condition of the spatial
% distribution of total oxygen concentration along the tube
[E0a,CMRO20a,Cx0,Cp0]=valabregue1f(F0,PS,Pt,Pa0);
Ct0=Pt*alpha;
F0=F0*(1/1000);
PS=PS*(1/1000);
CMRO20a=CMRO20a*(1000/22400);

% functional expressions
CMRO2max=CMRO20*(1+dCMRO2*mytrapezoid(t,fstart,fdur,framp*0.25));
F=F0*(1+dF*mytrapezoid(t+f_dt,fstart,fdur,framp));

% initialization
C=zeros(length(x),length(t));
C(:,1)=Cx0';
Ct(1)=Ct0;

% main loop
ddn=4; ddo=1; ddtol=1e-3;
for nn=1:length(t),
  for mm=1:length(x),

    Cp(mm,nn)=fminbnd(@C_Hb,1e-8,300,opt1min,C(mm,nn),[cHb PO alpha P50 hill]);

  end;
  Cp_bar(nn)=mean(Cp(:,nn));

  CMRO2(nn)=PS*(Cp_bar(nn)-Ct(nn));
  %CMRO2(nn)=CMRO20a;
  %CMRO2(nn) = CMRO2max(nn)*( Ct(nn)/(Km + Ct(nn)) );

  if (nn<length(t)),

    Ct(nn+1) = Ct(nn) + (dt/Vt)*( PS*( Cp_bar(nn) - Ct(nn) ) - CMRO2(nn) );
    %if (abs(Ct(nn+1)-C(nn))<(ddtol*Ct(nn))), Ct(nn+1)=C(nn); end;

    % assume no changes in vessel volume such that Ca=Ca0 for all time
    C(1,nn+1)=Cx0(1);
    for mm=2:length(x),

      Cterm1 = -F(nn)*L*( C(mm,nn) - C(mm-1,nn) )/dx;
      Cterm2 = PS*( Cp(mm-1,nn) - Ct(nn) );
      C(mm,nn+1) = C(mm,nn) + (dt/Vc)*( Cterm1 - Cterm2 );
      %if (abs(C(mm,nn+1)-C(mm,nn))<(ddtol*C(mm,nn))), C(mm,nn+1)=C(mm,nn); end;

    end;
    %dCx_hat=polyval(polyfit(x(end-ddn:end-1),diff(C(end-ddn:end,nn))',ddo),x(end));
    %C(mm+1,nn+1)=C(mm+1,nn)+(dt/Vc)*( -(F(nn)/dx)*dCx_hat*L - PS*(Cp(mm+1,nn)-Ct(nn)));

  end;

end;


E=1-C(1,:)./C(end,:);
CMRO2=CMRO2*(22400/1000);

