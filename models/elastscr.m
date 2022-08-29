
clear all
load elastvals

figure(1)
subplot(211)
plot(t*60,[Fin_1' Fout_1' Fout_2' Fout_4'])
axis('tight'), grid('on'),
ylabel('Flow (ml/min)'), xlabel('Time (s)'),
fatlines; dofontsize(15);
ax=axis; axis([2 40 ax(3:4)]),
legend('Fin','FoutEl','FoutExp','FoutHis')
subplot(212)
plot(t*60,[VV_1' VV_2' VV_4'])
axis('tight'), grid('on'),
ylabel('Volume (ml)'), xlabel('Time (s)'),
fatlines; dofontsize(15);
ax=axis; axis([2 40 ax(3:4)]),
legend('Vel','Vexp','Vhis')

figure(2)
plot(VV_1,Fout_1/50,VV_2,Fout_2/50,VV_4,Fout_4/50)
axis('tight'), grid('on'),
ylabel('rel. Flow'), xlabel('rel. Volume'),
fatlines; dofontsize(15);
legend('Vel','Vexp','Vhis',2)

figure(3)
subplot(211)
plot(t*60,[Fin_7' Fout_7' Fout_8'],t2*60,[Fout_9' Fout_0'])
axis('tight'), grid('on'),
ylabel('Flow (ml/min)'), xlabel('Time (s)'),
fatlines; dofontsize(15);
ax=axis; axis([2 40 ax(3:4)]),
legend('Fin','FoutEl','FoutEl2','FoutExp','FoutHis')
subplot(212)
plot(t*60,[VV_7' 0.005*(VV_8/VV_8(1)-1)'+VV_8(1)],t2*60,[VV_9' VV_0'])
axis('tight'), grid('on'),
ylabel('Volume (ml)'), xlabel('Time (s)'),
fatlines; dofontsize(15);
ax=axis; axis([2 40 ax(3:4)]),
legend('Vel','Vel2 / 200','Vexp','Vhis')

figure(4)
plot([VV_7' 0.005*(VV_8'/VV_8(1)-1)+VV_8(1)]/VV_7(1),[P_7' P_8']/P_7(1),[VV_9' VV_0']/VV_9(1),[P_9' P_0']/P_9(1))
axis('tight'), grid('on'),
ylabel('rel. Pressure'), xlabel('rel. Volume'),
fatlines; dofontsize(15);
legend('Vel','Vel2 / 200','Vexp','Vhis',2)

figure(5)
plot(t(1:end-1)*60,[C_7' 0.01*C_8'],t2(1:end-1)*60,[0.01*C_9' C_0'])
axis('tight'), grid('on'),
ylabel('rel. Flow'), xlabel('rel. Volume'),
fatlines; dofontsize(15);
legend('Cel','Cel / 100','Cexp / 100','Chis')

