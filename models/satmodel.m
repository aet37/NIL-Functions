
%ntau=4;
%T1alt=1.8;

%Mzalt=1;
%for n=1:ntau,
%  Mzalt = Mzalt + 2*((-1)^n)*exp(-x(n)/T1alt);
%end;

tsat=[0 400 600 800 1000 1200 1500 1800]*1e-3;
bsig=[1 .76 .67 .58 .51 .44 .36 .3];

% the blood signal in the saturation scheme falls as
%  y_blood = exp(-t/T1_blood)

ti=[0:length(tsat)+1]*tsat(end)/(length(tsat)+2);
bb=interp1(tsat,bsig,ti);

ai=gammafun(tsat*(5/.8),0);
ai=rect(ti,0.8,0.4);

y=conv(bb,ai);

