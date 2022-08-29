
clear all

opt1min=optimset('fminbnd');
dtol=1e-10;
dynamic_model_flag=0;
plots_flag=0;

L=400e-4;	% units: cm
dx=L/100;
x=[0:dx:L];	% units: cm

alpha=1.39e-3;	% units: mmol/L/mmHg
P50=26;		% units: mmHg
hill=2.73;
cHb=2.3;	% units: mmol/L
PO=4;

F0=50;		% units: ml/min

% calculate the initial condition first from the steady state solution
%   assume CMRO2 is given (units: mmol/min)
%     we can solve for either Ct, Cp (mmol/ml) or PS (ml/min)
%     PS has been reported around to be around 3000 to 7000 ml/min!
%     but this is likely dependent on the choice of L!
      PS=3000;
%   assume Cp_bar is known
%

%CMRO20=2.7938;
%Cp_bar=0.0065;
%PS=CMRO20/(Cp_bar-Ct);

Pa=80;		% units: mmHg
Pt=5;		% units: mmHg
Cpa=Pa*alpha;
Ca=Cpa+(cHb*PO)/(1+((P50/Pa)^hill));
Ct=Pt*alpha;
%Cpa=fminbnd(@C_Hb,1e-8,1e2,opt1min,Ca,[cHb PO alpha P50 hill]);

C(1)=Ca;
Cp(1)=Cpa;
for mm=2:length(x),
  C(mm) = C(mm-1) + dx*( -(PS/(F0*L))*( Cp(mm-1) - Ct ) );
  Cp(mm) = fminbnd(@C_Hb,1e-8,1e2,opt1min,C(mm),[cHb PO alpha P50 hill]);
end;
E=1-C(end)/C(1);

% verify?
Cp_bar_p=mean(Cp);
CMRO2_p=PS*(Cp_bar_p-Ct);


% now we have a steady-state calculation that can be used as initial
% condition, let's try to calculate the dynamic model

if (dynamic_model_flag),

T=1.0;		% units: min
dt=T/120;	% units: min (0.5 sec resolution)
t=[0:dt:T];

Vc=1;		% units: ml
Vt=96;		% units: ml

%F=F0*(1+0.4*mytrapezoid(t,12/60,12/60,4/60));
F=ones(size(t))*F0;
%CMRO2=ones(size(t))*CMRO20;
%CMRO2=ones(size(t))*CMRO2_p;
CMRO2=CMRO2_p*(1+0.00001*mytrapezoid(t,12/60,12/60,4/60));

CC(1,:)=C;
CCp(1,:)=Cp;
CCt(1)=Ct;
EE(1)=E;
for mm=2:length(t),

  CCp_bar=mean(CCp(mm-1,:));
  CCt(mm) = CCt(mm-1) + (dt/Vt)*( PS*(CCp_bar - CCt(mm-1)) - CMRO2(mm-1) );
  if (abs(CCt(mm)-CCt(mm-1))<dtol), CCt(mm)=CCt(mm-1); end;

  CC(mm,1)=Ca;
  CCp(mm,1)=Cpa;
  for nn=2:length(x),
    A =  -F(mm-1)*L*(CC(mm-1,nn) - CC(mm-1,nn-1))/dx;
    B =  PS*(CCp(mm-1,nn-1) - CCt(mm-1) );
    CC(mm,nn) = CC(mm-1,nn) + (dt/Vc)*( A - B );
    if (abs(CC(mm,nn)-CC(mm-1,nn))<dtol), CC(mm,nn)=CC(mm-1,nn); end;
    CCp(mm,nn) = fminbnd(@C_Hb,1e-8,1e2,opt1min,CC(mm,nn),[cHb PO alpha P50 hill]);
  end;
  EE(mm)=1-CC(mm,end)/CC(mm,1);

end;

end;

