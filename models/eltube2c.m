
clear all

t=[0:.01:100];
tlen=length(t);
h=t(2)-t(1);

% relevant values: 0.04 0.05 0.10 0.20, 20 21 22
u1=smrect(t,[0.10 10 20],1);
u2=smrect(t,[0.10 10 20],1);
%u1=zeros(size(t)); u1(1001:4000)=ones([1 3000]);
%u2=zeros(size(t)); u2(1001:4000)=ones([1 3000]);

f1base= 1.0e-6;
f2base= 1.0e-7;

f1tau1=5;
f1tau2=5;
f2tau1=15;
f2tau2=15;
f1amp=0.5;
f2amp=0.3;

f1(1)=0; 
f2(1)=0;
for m=1:tlen,
  if (m<tlen),
    f1(m+1)= f1(m) + h*( (1/f1tau1)*u1(m) - (1/f1tau2)*f1(m) );
    f2(m+1)= f2(m) + h*( (1/f2tau1)*u2(m) - (1/f2tau2)*f2(m) );
  end;

  Fin(m)= f1base*(1+f1amp*f1(m));
  V(m)= f2base*(1+f2amp*f2(m));
  
  if (m>1),
    Fout(m)= Fin(m) - (V(m)-V(m-1))/h;
  else,
    Fout(1)= Fin(1);
  end;

end;

k1=0;
k2=1;
k3=1;
k4=1;

%dQ= (k1*Fin*h + k2*V).*(1-Fout*h./V);
dQ= (1-Fout*h./V);
dS= (1./dQ);
dS= k4*(dS/dS(1)-1);

subplot(221)
plot(t,Fin,t,Fout)
xlabel('Time'), ylabel('Flow')
subplot(222)
plot(t,V)
xlabel('Time'), ylabel('Volume')
subplot(223)
plot(V./V(end),Fin./Fin(end))
xlabel('V/V0'), ylabel('F/F0')
subplot(224)
plot(t,dS)
xlabel('Time'), ylabel('dS (MR)')

% what this script does is determine the contribution of volume
% to the out-flow. it turns out that the volume change needs to
% be larger in order to drive large changes in the out-flow

% this script also shows the dependences on the signal observed
% as determined here. seems like the signal is inversely proportional
% to the fraction of deoxy's that remain in the compartment 
% assuming the intercoversion of oxy-to-deoxy is instantenous
% and our compartment sits on the venous side

