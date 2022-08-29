%
% Simulations to test the potentials sources of the BOLD post-stimulus
% undershoot. These simulations will concentrate on different ways to
% increase the venous amount of dHb. Two possibilities are tested:
%  1) venous volume effects (amplitude and time-constant)
%  2) venous blood oxygenation effects (CMRO2, extra-cellular tissue)
%

clear all

St0=2/60;
Sw=40/60;
Sr=0.1/60;
Namp=0;
Ntau=1.5/60;
Utau=2/60;
Ftau=6/60;
Famp=0.50;
Oamp=0.00;
F0=80;
V0=2;
Vtau=5/60;
Vamprat=1.0;
P50=26;
Vc=1.0;
Vct=97;
PS=7000;
Pa=90;
Pt=35;
Bk=0.18;
Bk2=1.0;
nctype=3;
Ctau=16/60;

tparms=[1/(60*20) 82/60];
if (Vc < 0.2),
    tparms(1)=1/(60*400);
end;

%       1  2   3  4  5    6    7    8  9  10  11  12  13  14  15  16  17  18  19   20    21  22     23    24
sparms1=[1 St0 Sw Sr Ftau Famp Oamp F0 V0 Vtau P50 Vc Vct  PS  Pa  Pt  Bk  Bk2 Namp Ntau Utau nctype Ctau Vamprat];

% P_CO2 tests
sparms2=sparms1; sparms2(10)=2/60;
sparms3=sparms1; sparms3(10)=16/60;
sparms4=sparms1; sparms4(12)=0.5;
sparms5=sparms1; sparms5(12)=5.0;
sparms6=sparms1; sparms6(9)=0.5; sparms7(13)=98.5;
sparms7=sparms1; sparms7(9)=10; sparms7(13)=90;


[BOLD_1,F_1,Fout_1,Vv_1,CMRO2_1,E_1,q_1,U_1,t_1,u_1,Ct_1,Cc_1]=myBOLDnc3([],tparms,sparms1,[]);
[BOLD_2,F_2,Fout_2,Vv_2,CMRO2_2,E_2,q_2,U_2,t_2,u_2,Ct_2,Cc_2]=myBOLDnc3([],tparms,sparms2,[]);
[BOLD_3,F_3,Fout_3,Vv_3,CMRO2_3,E_3,q_3,U_3,t_3,u_3,Ct_3,Cc_3]=myBOLDnc3([],tparms,sparms3,[]);
[BOLD_4,F_4,Fout_4,Vv_4,CMRO2_4,E_4,q_4,U_4,t_4,u_4,Ct_4,Cc_4]=myBOLDnc3([],tparms,sparms4,[]);
[BOLD_5,F_5,Fout_5,Vv_5,CMRO2_5,E_5,q_5,U_5,t_5,u_5,Ct_5,Cc_5]=myBOLDnc3([],tparms,sparms5,[]);
[BOLD_6,F_6,Fout_6,Vv_6,CMRO2_6,E_6,q_6,U_6,t_6,u_6,Ct_6,Cc_6]=myBOLDnc3([],tparms,sparms6,[]);
[BOLD_7,F_7,Fout_7,Vv_7,CMRO2_7,E_7,q_7,U_7,t_7,u_7,Ct_7,Cc_7]=myBOLDnc3([],tparms,sparms7,[]);

[BOLDmin_1,tmin_1]=min(BOLD_1-1); [BOLDmax_1,tmax_1]=max(BOLD_1-1); tmin_1=t_1(tmin_1); tmax_1=t_1(tmax_1);
[BOLDmin_2,tmin_2]=min(BOLD_2-1); [BOLDmax_2,tmax_2]=max(BOLD_2-1); tmin_2=t_2(tmin_2); tmax_2=t_2(tmax_2);
[BOLDmin_3,tmin_3]=min(BOLD_3-1); [BOLDmax_3,tmax_3]=max(BOLD_3-1); tmin_3=t_3(tmin_3); tmax_3=t_3(tmax_3);
[BOLDmin_4,tmin_4]=min(BOLD_4-1); [BOLDmax_4,tmax_4]=max(BOLD_4-1); tmin_4=t_4(tmin_4); tmax_4=t_4(tmax_4);
[BOLDmin_5,tmin_5]=min(BOLD_5-1); [BOLDmax_5,tmax_5]=max(BOLD_5-1); tmin_5=t_5(tmin_5); tmax_5=t_5(tmax_5);
[BOLDmin_6,tmin_6]=min(BOLD_6-1); [BOLDmax_6,tmax_6]=max(BOLD_6-1); tmin_6=t_6(tmin_6); tmax_6=t_6(tmax_6);
[BOLDmin_7,tmin_7]=min(BOLD_7-1); [BOLDmax_7,tmax_7]=max(BOLD_7-1); tmin_7=t_7(tmin_7); tmax_7=t_7(tmax_7);

RR=[
    BOLDmin_1/BOLDmax_1;
    BOLDmin_2/BOLDmax_2;
    BOLDmin_3/BOLDmax_3;
    BOLDmin_4/BOLDmax_4;
    BOLDmin_5/BOLDmax_5;
    BOLDmin_5/BOLDmax_6;
    BOLDmin_5/BOLDmax_7];
RR=abs(RR)',

save pco2sim_res1

figure(1)
subplot(411)
plot(t_1*60,[F_1;F_2;F_3;F_4;F_5;F_6;F_7]')
ylabel('F'); legend('1','2','3','4','5','6','7');
grid('on'); axis('tight'); fatlines; dofontsize(15);
subplot(412)
plot(t_1*60,[Vv_1;Vv_2;Vv_3;Vv_4;Vv_5;Vv_6;Vv_7]')
ylabel('V_v'); legend('1','2','3','4','5','6','7');
grid('on'); axis('tight'); fatlines; dofontsize(15);
subplot(413)
plot(t_1*60,[Cc_1;Cc_2;Cc_3;Cc_4;Cc_5;Cc_6;Cc_7]')
ylabel('C_c'); legend('1','2','3','4','5','6','7');
grid('on'); axis('tight'); fatlines; dofontsize(15);
subplot(414)
plot(t_1*60,[BOLD_1;BOLD_2;BOLD_3;BOLD_4;BOLD_5;BOLD_6;BOLD_7]')
ylabel('BOLD'); legend('1','2','3','4','5','6','7');
grid('on'); axis('tight'); fatlines; dofontsize(15);

figure(2)
subplot(311)
plot([normch(F_1/F_1(1),1);normch(BOLD_1,1);normch(BOLD_2,1);normch(BOLD_3,1)].')
legend('F1','B1','B2','B3');
grid('on'); axis('tight'); fatlines; dofontsize(15);
subplot(312)
plot([normch(F_1/F_1(1),1);normch(BOLD_1,1);normch(BOLD_4,1);normch(BOLD_5,1)].')
legend('F1','B1','B4','B5'); ylabel('Normalized Change');
grid('on'); axis('tight'); fatlines; dofontsize(15);
subplot(313)
plot([normch(F_1/F_1(1),1);normch(BOLD_1,1);normch(BOLD_6,1);normch(BOLD_7,1)].')
legend('F1','B1','B6','B7');
grid('on'); axis('tight'); fatlines; dofontsize(15);

