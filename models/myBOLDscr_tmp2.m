
rCBF=1.62;
rCMRO2=1.24;
rBOLD=1.036;

F0=55;
PS=7000;
Pa=500;
Pt=43.4;

tparms=[1/(60*20) 1.2];
sparms=[1 3.5/60 29.8/60 0.2/60 3/60 rCBF-1 rCMRO2-1 F0 1 0.2 26 1 96 PS Pa Pt 0.5 1];
sparms=[sparms  0.0   1.5/60   2.0/60   0  2.0/60];
sparms(12:13)=[1 98];
sparms(19)=0.5;
sparms(22)=0;

sparms1=sparms;
sparms2=sparms;
sparms3=sparms;
sparms4=sparms;

sparms1([8 14 15 16])=[F0 PS 100 28.7];
sparms2([8 14 15 16])=[F0 PS 500 43.4];
sparms3([8 14 15 16])=[F0 PS 100 27.9];
sparms4([8 14 15 16])=[F0 PS 500 41.2];

[St1,Fin1,Fout1,VV1,CMRO2t1,EEt1,q1,Ut1,t,UUt1,CCt1,CCc1]=myBOLDnc2([],tparms,sparms1,[]);
for mm=1:length(sparms1),
  for nn=1:length(sparms1),
    sparms2=sparms1;
    sparms3=sparms1;
    sparms2(mm)=1.01*sparms1(mm);
    sparms3(nn)=1.01*sparms1(nn);
    [St2,Fin2,Fout2,VV2,CMRO2t2,EEt2,q2,Ut2,t,UUt2,CCt2,CCc2]=myBOLDnc2([],tparms,sparms2,[]);
    [St3,Fin3,Fout3,VV3,CMRO2t3,EEt3,q3,Ut3,t,UUt3,CCt3,CCc3]=myBOLDnc2([],tparms,sparms3,[]);
    HH(mm,nn)=sum(1.0.*((St2-St1)/(0.01*sparms2(mm))).*((St3-St1)/(0.01*sparms3(nn))));
    PP(mm,nn)=sparms2(mm)*sparms3(nn);
    [mm nn length(sparms1)],
  end;
end;

save myBOLDscr_HH0res
 
