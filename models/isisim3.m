
% all times in ms

c = [1 0];
t = [0:1000:((5*60*1000)-1000)];
%parms = [1 2500 1250];
parms = [1 8.6 550];
tvects1=0;

for lp = 1:10,
  for lp2 = 1:50,
    dt = (lp2)*1000;
    times2 = [-20000:dt:((5*60*1000)-100)];
    toff = rand(size(times2)).*2000.*(lp-1);
    times3 = -20000 + cumsum(dt+toff);
    tvects = mkgam3( times3, t, parms)./((1000).^(8.6));
    tvects1 = tvects1 + tvects;

    e1 = ones(size(t))';
    tv1 = tvects';
    %normalize
    tv1 = tv1 - e1*mean(tv1);
    %  tv1 = tv1./ sum(tv1.^2);

    P = [tv1 e1];
    iP = inv(P'*P);
    tr(lp,lp2) = trace(iP);
    cv(lp,lp2) = c*iP*c';
    del(lp,lp2) = dt + 1000*(lp-1);

    %plot(P)
  
  end;
end;

clf
semilogy(del'./1000,cv')
axis([0 20 0.5E-6 1E-2])
pause

clf
for lp=1:3,
  dt = 5000;
  times2 = [-20000:dt:((5*60*1000)-100)];
  toff = (rand(size(times2))-0.5).*4000.*(lp-1);
  times3 = -20000 + cumsum(dt+toff);
  tvects = mkgam3( times3, t, parms)./((1000).^(8.6));
  tv(lp,:) = tvects;
end;
tv = tv./100;

subplot(311)
plot(t./1000,tv(1,:))
axis([0 300 0 2])
subplot(312)
plot(t./1000,tv(2,:))
axis([0 300 0 2])
subplot(313)
plot(t./1000,tv(3,:))
axis([0 300 0 2])

