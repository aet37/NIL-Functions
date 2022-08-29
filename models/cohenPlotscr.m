
ti=tii;
rcmro2=e.*mean(qin')'; rcmro2=rcmro2/rcmro2(1);

subplot(231)
plot(ti,qin./(qin(1,:)'*ones(1,length(ti)))')
axis('tight'), grid('on')
legend('artl','cap','venl')
xlabel('Time (s)')
ylabel('In Flow')
title(sprintf('Qin_0 = %1.2e mm^3/s',qin(1,1)));

subplot(232)
plot(ti,v./(v(1,:)'*ones(1,length(ti)))')
axis('tight'), grid('on')
legend('artl','cap','venl')
xlabel('Time (s)')
ylabel('Volume')
title(sprintf('V_0 = [ %1.2e %1.2e %1.2e ] mm^3',v(1,1),v(1,2),v(1,3)));

mttsum=sum(mtt')';
subplot(233)
plot(ti,mtt)
axis('tight'), grid('on')
legend('artl','cap','venl')
xlabel('Time (s)')
ylabel('Mean Transit Time')
title(sprintf('Total MTT = %1.2f min/max=%1.2fs/%1.2fs',mttsum(1),min(mttsum),max(mttsum)));

subplot(234)
plot(ti,e)
axis('tight'), grid('on')
xlabel('Time (s)')
ylabel('O2 Extraction')
title(sprintf('%% end dE = %1.2f %%',(e(1)/min(e)-1)*100));

subplot(235)
plot(ti,q)
axis('tight'), grid('on')
xlabel('Time (s)')
ylabel('Amt deoxy-Hb')

subplot(236)
plot(ti,s)
axis('tight'), grid('on')
xlabel('Time (s)')
ylabel('% MR Signal Change')

%print -depsc -tiff -r600 cohenHyperDetail.eps

