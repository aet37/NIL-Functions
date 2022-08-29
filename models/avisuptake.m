function [OUT,t]=avisuptake(x,parms,parmstofit,output,uptimes,updata)
% Usage ... f=avisuptake(x,parms,parmstofit,output,data)
%
% x = sample [L0 Qartle Qtiss B0]
% parms = [dt T L0 B0 Qartle Vartle Qcap Vcap Qtiss Vtiss T1bl T1tiss]
% output = [1=A+C+T 2=C+T 3=[A C T]]

% example:
% avisuptake([30 4 0.1],[.01 1.5 1 4 96 1.0 1.0 1.0],1);
% avisuptake([],[.01 1.5 19 5 1 1 1 1 1 1 1.5 1.5],[],1,UPTi,UP11i);

if (~isempty(x)),
  parms(parmstofit)=x;
end;

% conversion factors
cm2m=1e-2;
m2cm=1/cm2m;
mmHg2Pa=133.32;
Pa2mmHg=1/133.32;
ml2m3=1e-6;
m32ml=1/ml2m3;

% physiological constants
L0=parms(3);		% mol (eg. 50)
B0=parms(4);		% baseline offset (eg. 0)

Qartle=parms(5)*ml2m3;	% m3/s (eg. 2)
Vartle=parms(6)*ml2m3;	% m3 (eg. 1)

Qcap=parms(7)*ml2m3;	% m3/s (eg. 0.5)
Vcap=parms(8)*ml2m3;	% m3 (eg. 0.5)

Qtiss=parms(9)*ml2m3;	% m3/s (eg. 0.1)
Vtiss=parms(10)*ml2m3;	% m3 (eg. 96)

% other constants
R1bl=1/parms(11);	% 1/s (eg. 0.8, 1.5)
R1tiss=1/parms(12);	% 1/s

% perfusion rates ??? 
f=Qtiss/Vcap;
fo=Qtiss/Vtiss;
k1=Qartle*m32ml;
k2=Qtiss*m32ml;

% time vector
dt=parms(1);		% s (eg. 0.01)
T=parms(2);		% s (eg. 40)
t=[0:dt:T];

% label input function
L=L0*exp(-t*R1bl);

% simulation
Vartle(1)=Vartle;
A(1)=0; A1(1)=0; A2(1)=0;
C(1)=0;
T(1)=0;
y(1)=0;
for mm=2:length(t),

  kac=Qcap/Qartle;	% hummm ???

  A(mm) = A(mm-1) + dt*( (Qartle/Vartle)*L(mm-1) - (Qartle/Vartle)*A(mm-1) - R1bl*A(mm-1)  );

  C(mm) = C(mm-1) + dt*( kac*(Qartle/Vartle)*A(mm-1) - f*C(mm-1) + fo*T(mm-1) - (Qcap/Vcap)*C(mm-1) - R1bl*C(mm-1) );

  T(mm) = T(mm-1) + dt*( f*C(mm-1) - fo*T(mm-1) );

  A1(mm) = A1(mm-1) + dt*( (Qartle/Vartle)*L0 - (Qartle/Vartle)*A1(mm-1) );

  A2(mm) = A2(mm-1) + dt*( k1*L(mm-1) - k2*A2(mm-1) );

end;

CT=C+T;
TOTAL=A+C+T;

MTTartle = Vartle/Qartle;
MTTcap = Vcap/Qcap;

if (output==1),
  OUT=TOTAL;
elseif (output==2),
  OUT=A;
elseif (output==3),
  OUT=CT;
elseif (output==4),
  OUT=A1;
elseif (output==5),
  OUT=A2;
else,
  OUT=[A C T];
end;
OUT=OUT+B0;

if (nargin>4),
  OLDOUT=OUT;
  OUTDATA=interp1(t,OLDOUT,uptimes);
  OUT=OUTDATA-updata;
  [x sum(OUT.*OUT)],
  if (nargout==0),
    plot(t,OLDOUT,uptimes,updata)
  end;
end;


if (nargout==0)&(nargin<5),
  plot(t,L,t,A,t,C,t,T)
  legend('Input','Artle','Cap','Tiss')
  if (output>3),
    plot(t,OLDOUT)
  end;
  if (nargin>4),
    plot(t,OLDOUT,uptimes,updata)
    %plot(t,OLDOUT,uptimes,updata,t,A+B0,'--')
  end;
  xlabel('Time (s)')
  ylabel('Signal')
  axis('tight'), grid('on'),
  dofontsize(15);
end;  

