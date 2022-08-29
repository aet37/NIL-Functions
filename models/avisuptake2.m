function [OUT,t,A,CT]=avisuptake2(x,parms,parmstofit,output,uptimes,updata)
% Usage ... f=avisuptake2(x,parms,parmstofit,output,data)
%
% x = sample [L0 Qartle Qtiss B0]
% parms = [dt T L0 B0 k1 k2 k3 k4 T1bl T1tiss]
% output = [1=A+C+T 2=C+T 3=[A C T]]

% example:
% avisuptake([30 4 0.1],[.01 1.5 1 4 96 1.0 1.0 1.0],1);
% avisuptake([],[.01 1.5 19 5 1 1 1 1 1 1.5 1.5],[],1,UPTi,UP11i);

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

k1=parms(5);
k2=parms(6);
k3=parms(7);
k4=parms(8);
k5=parms(9);
k6=parms(10);
R1bl=parms(11);
R1tiss=parms(12);
if (k2==0), CTtt=0; else, CTtt=1/k2; end;

% time vector
dt=parms(1);		% s (eg. 0.01)
T=parms(2);		% s (eg. 40)
t=[0:dt:T];

% label input function
L=L0*exp(-t*R1bl);
%L=L0.*ones(size(t));

% simulation
A(1)=0; A1(1)=0; A2(1)=0;
C(1)=0; CT(1)=0;
T(1)=0;
y(1)=0;
CTtti=round(CTtt/dt);
for mm=2:length(t),

  A(mm) = A(mm-1) + dt*( k1*L(mm-1) - k2*A(mm-1) - R1bl*A(mm-1) );

  if ((mm-2)<=CTtti),
    CT(mm)=0;
  else,
    CT(mm) = CT(mm-1) + dt*( k3*A(mm-1-CTtti) - k4*CT(mm-1) - R1tiss*CT(mm-1) );
  end; 

  C(mm) = C(mm-1) + dt*( k3*A(mm-1) - k4*C(mm-1) + k5*T(mm-1) - k6*C(mm-1) - R1bl*C(mm-1) );

  T(mm) = T(mm-1) + dt*( k4*C(mm-1) - k5*T(mm-1) - R1tiss*T(mm-1) );

  A1(mm) = A1(mm-1) + dt*( k1*L0 - k1*A1(mm-1) );

  A2(mm) = A2(mm-1) + dt*( k1*L(mm-1) - k2*A2(mm-1) );

end;

%CT=C+T;
TOTAL=A+CT;


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
  uptimesi=[uptimes(1):t(2)-t(1):uptimes(end)];
  updatai=interp1(uptimes,updata,uptimesi);
  OLDOUT=OUT;
  OUTDATA=interp1(t,OLDOUT,uptimes);
  OUT=OUTDATA-updata;
  %OUTDATA=interp1(t,OLDOUT,uptimesi);
  %OUT=OUTDATA-updatai;
  %OUT=abs(OUT);
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

