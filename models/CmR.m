
clear all

Pi=45;		% 45 mmHg
Rn=35;		% 35 mm
hn=7;		% 7 mm
fmax=1.3;
lambda=0.15;	% young=0.15, old=0.25;
gf=0.36;

Rmax=fmax*Rn;
hmax=sqrt(Rmax^2+2*Rn*hn+hn^2)-Rmax;
Rref=0.5*Rn;
href=sqrt(Rref^2+2*Rn*hn+hn^2)-Rref;

fmax2=1.25;		% typically 1.22
R=[1/fmax2:0.01:fmax2]*Rn;
h=(R.^2 + 2*Rn*hn + hn^2).^(0.5) - R;

num=0.5*((R/Rref).^2 - 1);

den1=Pi*(R./h-Rref/href);
den2=Rmax*hn/(lambda*Rn*hmax);
den3=Pi*lambda*(Rn/hn)*(den2.^((R-Rn)/(Rmax-Rn)) - den2.^((Rref-Rn)/(Rmax-Rn)));

Cm=num./(den1-den3);
dCmdR=diff(Cm)./diff(R);


figure(1)
plot(Cm,R)
xlabel('Compliance (1/mmHg)')
ylabel('Radius (um)')
axis('tight'), grid('on'), fatlines; dofontsize(15);

fitCm=0;
if (fitCm),
  [a2,Rmax,a1,R_fit]=calcExpRec(Cm(:),R(:),[Rmax 0.5 1.0]);
  hold('on')
  plot(Cm,R_fit,'r')
  fatlines; legend('Model','Fit');
  hold('off');

  ii=19;	% normo baseline 35 um
  ii_hypo=13;	% sqrt(0.75)*35 is 30um, assume 33 (13), velocity compromise
  ii_hyper=26;	% sqrt(1.27)*35 is 39um, assume 37 (26), velocity compromise

  cm1=gf*[4*a1*a2*(Rmax/Rn)*Cm(ii)*exp(-a2*Cm(ii))];
  cm2=gf*[4*a1*a2*(Rmax/Rn)*Cm(ii_hypo)*exp(-a2*Cm(ii_hypo))];
  cm3=gf*[4*a1*a2*(Rmax/Rn)*Cm(ii_hyper)*exp(-a2*Cm(ii_hyper))];
  [cm2/cm1 cm3/cm1],

  tau_vm=[0.55 0.05 0.33];
  tau_vp=[15.79 14.76 11.55];
  [tau_vm(2)/tau_vm(1) tau_vm(3)/tau_vm(1) tau_vp(2)/tau_vp(1) tau_vp(3)/tau_vp(1)],
end;

