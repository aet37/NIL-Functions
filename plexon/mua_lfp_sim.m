
clear all

n_neurons=20;
t_jitter=50e-3;;
A_syn=2;
A_ap=20;

tt=[0:1/44.1e3:1];
t_poisson=exp(-12*tt).*((12*tt).^3);
t0n=t_jitter*ran_dist(t_poisson(:),rand(1,n_neurons));

t0=0.2;
for mm=1:n_neurons,
  t00=t0n(mm)+0.2;
  y_ap=A_ap*gammafun(tt,t00+5e-3,0.004,0.05);
  y_syn=log(gammafun(tt,t00,0.005,2.2)*1e10+1);
  y_syn=A_syn*y_syn/max(y_syn);
  y(:,mm)=y_ap+y_syn;
end;
yy=sum(y')';

tt2=[0:1/2e4:1];
yy2=interp1(tt,yy,tt2);

