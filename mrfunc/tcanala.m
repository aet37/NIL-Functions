function out=tcanala(timecourse,inputcourse,cycles)
%
% Usage ... out=tcanala(timecourse,inputcourse,cycles)
%
% Fits exponentials
%
%
%

imperc=length(timecourse)/cycles;
tax=1:imperc;
tau1=1:cycles; tau2=1:cycles;

for n=1:cycles,
  true=1;
  tmpc(n,1:imperc)=timecourse((n-1)*imperc+1:n*imperc);
  tmpc(n,1:imperc)=tmpc(n,1:imperc)-min(min(tmpc(n,1:imperc)));
  tau1(n)=20;
  tau2(n)=5;
 
  while (true),
    figure(1);
    clg;
    exp1(n,1:imperc)=(tmpc(n,1)-0.30*tmpc(n,1))*exp(-tax/tau1(n));
    exp2(n,1:imperc)=(tmpc(n,1)+0.15*tmpc(n,1))*exp(-tax/tau2(n));
    plot(tax,tmpc(n,:),tax,exp1(n,:),tax,exp2(n,:));
    disp('Tau1 = '); disp(tau1(n));
    disp('Tau2 = '); disp(tau2(n));
    tmpi1=input('Exp1 Tau = ');
    tmpi2=input('Exp2 Tau = ');
    if ( (tmpi1==0)&(tmpi2==0) ), 
      true=0;
    else
      tau1(n)=tmpi1;
      tau2(n)=tmpi2;
    end;
  end;
end;

out=[mean(tau1) mean(tau2)];
