function [Q1a,UU,u1,t]=complG3f(x,tparms,xparms,parms2fit,data,tdata,wdata)
% Usage ... complG3f(x,tparms,xparms,parmstofit,data,tdata,wdata)

dt=tparms(1);
tfin=tparms(2);		
t=[0:dt:tfin];		% units: Time (minutes)

if (length(tparms)>2), BOLDtype=tparms(3); else, BOLDtype=0; end;

% Model 1: Simple Balloon Approach
%
%  dQa/dt = kq1 * u(t) - kq2 * Qa + kq5 * du/dt
%

if (length(parms2fit)>0),
  xparms(parms2fit)=x;
end;


Qa0=xparms(1);		% units: Volume/Time (ml/min)
V0=xparms(2);		% units: Volume (ml)

kq2=1/(xparms(3)/60);	% units: 1/Time
kq1=xparms(8);		% units: Flow/Time
kn=1/(xparms(4)/60);	% units: 1/Time
kq5=xparms(5)*25.0;	% units: dimmensionless

% Model 2: Dimmensional Equations
%
%  dRa/dt = kr1 * u(t) - kr2 * Ra
%

Pa=50;		% units: Pressure (mmHg)
Pv=10;		% units: Pressure (mmHg)
Pc=0;		% units: Pressure (mmHg)

P0=0.5*(Pa+Pv);		% units: Pressure (mmHg)

Ra0=(Pa-P0)/Qa0;	% units: Resistance = Pressure / Flow (mmHg/ml/min)
Rv=(P0-Pv)/Qa0;		% units: Resistance = Pressure / Flow (mmHg/ml/min)
Rv=Ra0;

kr2=1/(2/60);	% units: 1/Time
kr1=kr2*Ra0;	% units: Resistance/Time

C0=0.5*1/10;	% units: Volume/Pressure (ml/mmHg)

%
% Input Function (Rectangular, well actually Trapezoidal)
%
ust=xparms(6)/60;	% start time of rectangle function (disturbance)
udur=xparms(7)/60;	% duration of disturbance
uramp=0.1/60;	        % transition duration of disturbance
u1amp=xparms(8);	% disturbance amplitude for model 1
u2amp=-1/(1+xparms(8));	% disturbance amplitude for model 2

%u1type=[10 1e7 200/60 0.02];
u1type=[14 xparms(9) xparms(10)];
u2type=[14 xparms(9) xparms(10)];

u1=mytrapezoid2(t,ust,udur,uramp,u1type);
u2=mytrapezoid2(t,ust,udur,uramp,u2type);


%
% Solve equations in dimmensional form since they are simple
%
UU(1)=0;
Q1a(1)=Qa0; 
Ra(1)=Ra0;
Q2a(1)=Qa0;
for mm=2:length(t),

  %
  % Model 1: Euler method
  %
  UU(mm) = UU(mm-1) + dt*( kn*(u1(mm-1) - UU(mm-1))  );
  Q1a(mm) = Q1a(mm-1) + dt*( kq2*((kq1*UU(mm-1)+1) - Q1a(mm-1)) + kq5*(u1(mm)-u1(mm-1))/dt );

  %
  % Model 2: Euler method
  %
  Ra(mm) = Ra(mm-1) + dt*( kr1*u2(mm-1) - kr2*Ra(mm-1) );
  Q2a(mm) = (Pa-P0)/Ra(mm);

end;

if (BOLDtype),
  kb=xparms(11);
  mtt=xparms(12);
  kv=xparms(13);
  e0=xparms(14);
  b0=xparms(15);
  te=xparms(16);
  [BOLD,VV,EE]=simpleBOLD2(Q1a/Qa0,[dt kb mtt kv e0 b0 te]);
end;

if (BOLDtype==1),
  Q1a=BOLD;
end;

if (nargin>=5),
  for mm=1:size(data,1),
    datai(mm,:)=interp1(tdata,data(mm,:),t);
    wdatai(mm,:)=interp1(tdata,wdata(mm,:),t);
  end;
  if (BOLDtype==2),
    err2=(datai-[Q1a/Q1a(1);BOLD]);
    err=[wdatai(1,:).*err2(1,:)/max(datai(1,:)-1) wdatai(2,:).*err2(2,:)/max(datai(2,:)-1)];
    %subplot(211),plot(t',err2'),subplot(212),plot([t t],err), size(err),pause,
  else,
    err=wdatai.*(datai-Q1a);
  end;
  [x sum(err.^2)],
  if (nargout==0),
    plot(t,datai,t,Q1a)
  end;
  Q1a=err;
end;

if ((nargin<5)&(BOLDtype==2)),
  Q1a=[Q1a;BOLD];
end;

