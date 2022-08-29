
clear all

n_neurons=20;
t_jitter=50e-3;;
A_syn=2;
A_ap=20;

fs=44.1e3;
tt=[0:1/fs:1];
t_poisson=exp(-12*tt).*((12*tt).^3);
t0n=t_jitter*ran_dist(t_poisson(:),rand(1,n_neurons));

t0=0.2;
for mm=1:n_neurons,
  t00=t0n(mm)+0.2;
  y_ap=A_ap*gammafun(tt,t00+4e-3,0.003,0.03);
  y_syn=log(gammafun(tt,t00,0.005,2.2)*1e10+1);
  y_syn=A_syn*y_syn/max(y_syn);
  y(:,mm)=y_ap+y_syn;
end;
yy=sum(y')';

fs2=20e3;
tt2=[0:1/fs2:1];
yy2=interp1(tt,yy,tt2);

%wavwrite(yy/max(yy),44100,'intracell_sim_44p1khz.wav')
%wavwrite([yy;yy;yy;yy;yy;yy;yy;yy;yy;yy]/max(yy),44100,'intracell_sim_many_44p1khz.wav')
yys=wavread('intracell_sim_44p1khz.wav');

figure(1)
subplot(211)
ff=[1:length(tt)]-1; ff=ff*fs/max(ff);
plot(ff,abs(fft(yy-mean(yy))))
axis('tight'), tmpax=axis; axis([0 fs/4 tmpax(3:4)/10]),
subplot(212)
ff2=[1:length(tt2)]-1; ff2=ff2*fs2/max(ff2);
plot(ff2,abs(fft(yy2-mean(yy2))))
axis('tight'), tmpax=axis; axis([0 fs2/4 tmpax(3:4)/10]),

figure(2)
subplot(311)
plot(tt,yy)
grid('on'), axis('tight'), tmpax=axis; axis([0.2 0.35 tmpax(3:4)]),
subplot(312)
plot(tt,yys)
grid('on'), axis('tight'), tmpax=axis; axis([0.2 0.35 tmpax(3:4)]),
subplot(313)
plot(tt2,yy2)
grid('on'), axis('tight'), tmpax=axis; axis([0.2 0.35 tmpax(3:4)]),


