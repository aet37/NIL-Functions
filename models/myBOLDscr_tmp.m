
rCBF=1.62;
rCMRO2=1.24;
rBOLD=1.036;

F0=55;
PS=7000;
Pa=500;
Pt=43.4;

tparms=[1/(60*20) 1.4];
sparms=[1 3.5/60 29.8/60 0.2/60 3/60 rCBF-1 rCMRO2-1 F0 1 0.2 26 1 96 PS Pa Pt 0.5 1];
sparms=[sparms  0.0   1.5/60   2.0/60   0  2.0/60];
sparms(12:13)=[1 98];
sparms(22)=1;

load cmro2fitvals8c_3_60

sparms1=sparms;
sparms2=sparms;
sparms3=sparms;
sparms4=sparms;
sparms5=sparms;
sparms6=sparms;
sparms7=sparms;
sparms8=sparms;

sparms1([8 14 15 16])=[F0 PS 100 28.7];
sparms2([8 14 15 16])=[F0 PS 500 43.4];
sparms3([8 14 15 16])=[F0 PS 100 27.9];
sparms4([8 14 15 16])=[F0 PS 500 41.2];
sparms7([8 14 15 16])=[40 PS 500 30.6];
sparms8([8 14 15 16])=[75 PS 500 55.4];

%tic,[St1,Fin1,Fout1,VV1,CMRO2t1,EEt1,q1,Ut1,t,UUt1,CCt1,CCc1]=myBOLDnc2([],tparms,sparms1,[]);toc1=toc,
%tic,[St2,Fin2,Fout2,VV2,CMRO2t2,EEt2,q2,Ut2,t,UUt2,CCt2,CCc2]=myBOLDnc2([],tparms,sparms2,[]);toc2=toc,
%tic,[St3,Fin3,Fout3,VV3,CMRO2t3,EEt3,q3,Ut3,t,UUt3,CCt3,CCc3]=myBOLDnc2b([],tparms,sparms3,[]);toc3=toc,
%tic,[St4,Fin4,Fout4,VV4,CMRO2t4,EEt4,q4,Ut4,t,UUt4,CCt4,CCc4]=myBOLDnc2b([],tparms,sparms4,[]);toc4=toc,

tic,[St1,Fin1,Fout1,VV1,CMRO2t1,EEt1,q1,Ut1,t,UUt1,CCt1,CCc1]=myBOLDnc2(x8,tparms,sparms1,parms2fit);toc1=toc,
tic,[St2,Fin2,Fout2,VV2,CMRO2t2,EEt2,q2,Ut2,t,UUt2,CCt2,CCc2]=myBOLDnc2(x8,tparms,sparms2,parms2fit);toc2=toc,
tic,[St3,Fin3,Fout3,VV3,CMRO2t3,EEt3,q3,Ut3,t,UUt3,CCt3,CCc3]=myBOLDnc2b(x8,tparms,sparms3,parms2fit);toc3=toc,
tic,[St4,Fin4,Fout4,VV4,CMRO2t4,EEt4,q4,Ut4,t,UUt4,CCt4,CCc4]=myBOLDnc2b(x8,tparms,sparms4,parms2fit);toc4=toc,

tic,[St7,Fin7,Fout7,VV7,CMRO2t7,EEt7,q7,Ut7,t,UUt7,CCt7,CCc7]=myBOLDnc2b(x8,tparms,sparms7,parms2fit);toc7=toc,
tic,[St8,Fin8,Fout8,VV8,CMRO2t8,EEt8,q8,Ut8,t,UUt8,CCt8,CCc8]=myBOLDnc2b(x8,tparms,sparms8,parms2fit);toc8=toc,

figure (1)
subplot(413)
plot(t*60,CMRO2t4/CMRO2t4(1),'b--',t*60,CMRO2t3/CMRO2t3(1),'g-')
ylabel('CMR_{O2}'),
legend('Hyperoxia','Normoxia')
axis('tight'), grid('on'),
fatlines; dofontsize(15);
subplot(414)
plot(t*60,CCt4/CCt4(1),'b--',t*60,CCt3/CCt3(1),'g-')
ylabel('Tissue P_{O2}'),
axis('tight'), grid('on'),
fatlines; dofontsize(15);
subplot(411)
plot(t*60,Fin4/Fin4(1),'b--',t*60,Fin3/Fin3(1),'g-')
ylabel('F_{in}'),
axis('tight'), grid('on'),
fatlines; dofontsize(15);
subplot(412)
plot(t*60,St4,'b--',t*60,St3,'g-')
ylabel('BOLD'), xlabel('Time'),
axis('tight'), grid('on'),
fatlines; dofontsize(15);



sparms5([6 7 8 14 15 16])=[rCBF-1 0.0   F0 PS 500 41.2];
sparms6([6 7 8 14 15 16])=[0.0 rCMRO2-1 F0 PS 500 41.2];

tic,[St5,Fin5,Fout5,VV5,CMRO2t5,EEt5,q5,Ut5,t,UUt5,CCt5,CCc5]=myBOLDnc2b(x8,tparms,sparms5,parms2fit);toc5=toc,
tic,[St6,Fin6,Fout6,VV6,CMRO2t6,EEt6,q6,Ut6,t,UUt6,CCt6,CCc6]=myBOLDnc2b(x8,tparms,sparms6,parms2fit);toc6=toc,

figure(2)
subplot(413)
plot(t*60,CMRO2t4/CMRO2t4(1),'b-',t*60,CMRO2t5/CMRO2t5(1),'g--',t*60,CMRO2t6/CMRO2t6(1),'r-.')
ylabel('CMR_{O2}'),
axis('tight'), grid('on'),
fatlines; dofontsize(15);
subplot(414)
plot(t*60,CCt4/CCt4(1),'b-',t*60,CCt5/CCt5(1),'g--',t*60,CCt6/CCt6(1),'r-.')
ylabel('Tissue P_{O2}'),
axis('tight'), grid('on'),
fatlines; dofontsize(15);
subplot(411)
plot(t*60,Fin4/Fin4(1),'b-',t*60,Fin5/Fin5(1),'g--',t*60,Fin6/Fin6(1),'r-.')
ylabel('F_{in}'),
axis('tight'), grid('on'),
fatlines; dofontsize(15);
legend('Normal (Case 4)','\DeltaCMRO2=0','\DeltaCBF=0')
subplot(412)
plot(t*60,St4,'b-',t*60,St5,'g--',t*60,St6,'r-.')
ylabel('BOLD'), xlabel('Time'),
axis('tight'), grid('on'),
fatlines; dofontsize(15);

figure(3)
subplot(411)
plot(t*60,CMRO2t4/CMRO2t4(1),'-',t*60,CMRO2t7/CMRO2t7(1),'-',t*60,CMRO2t8/CMRO2t8(1),'-')
ylabel('CMR_{O2}'),
axis('tight'), grid('on'),
fatlines; dofontsize(15);
subplot(412)
plot(t*60,CCt4/CCt4(1),'-',t*60,CCt7/CCt7(1),'-',t*60,CCt8/CCt8(1),'-')
ylabel('Tissue P_{O2}'),
axis('tight'), grid('on'),
fatlines; dofontsize(15);
subplot(413)
plot(t*60,Fin5/Fin5(1),'-',t*60,Fin6/Fin6(1),'-',t*60,Fin8/Fin8(1),'-')
ylabel('F_{in}'),
axis('tight'), grid('on'),
fatlines; dofontsize(15);
subplot(414)
plot(t*60,St4,'-',t*60,St7,'-',t*60,St8,'-')
ylabel('BOLD'), xlabel('Time'),
legend('F_0 = 55','F_0 = 40','F_0 = 75')
axis('tight'), grid('on'),
fatlines; dofontsize(15);

