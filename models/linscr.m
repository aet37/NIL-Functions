
clear all
load temporal_data

opt6=optimset('lsqnonlin');

yy=ad_13;
%yy=ad_13+ad_14+ad_8+ad_9; yy=yy/4;

tti=[tt(1):(tt(2)-tt(1))/20:tt(end)];
ttc=(tti>20)&(tti<50);
yyi=interp1(tt',yy,tti');

parms=[20 4 0.1 0.02 0.1 0.2 0.3];
plb=[18 0.5 0.05 1e-8 1e-6 1e-6 1e-6];
pub=[25 16 4 1e4 1e6 1e6 1e6];

parms2fit=[1 2 3 4 5 6 7];
parms1=parms; parms1(2)=3;
parms2=parms; parms2(2)=4;
parms4=parms; parms4(2)=6;
parms8=parms; parms8(2)=10;
xx1=lsqnonlin(@linf,parms1(parms2fit),plb(parms2fit),pub(parms2fit),opt6,parms,parms2fit,tti,yyi(:,1));
xx2=lsqnonlin(@linf,parms2(parms2fit),plb(parms2fit),pub(parms2fit),opt6,parms,parms2fit,tti,yyi(:,2));
xx4=lsqnonlin(@linf,parms4(parms2fit),plb(parms2fit),pub(parms2fit),opt6,parms,parms2fit,tti,yyi(:,3));
xx8=lsqnonlin(@linf,parms8(parms2fit),plb(parms2fit),pub(parms2fit),opt6,parms,parms2fit,tti,yyi(:,4));
%linf(parms,parms,parms2fit,tti,ad13i(:,2));
[bold1i,uu1i]=linf(xx1,parms,parms2fit,tti);
[bold2i,uu2i]=linf(xx2,parms,parms2fit,tti);
[bold4i,uu4i]=linf(xx4,parms,parms2fit,tti);
[bold8i,uu8i]=linf(xx8,parms,parms2fit,tti);

xxx=[xx1;xx2;xx4;xx8];
xxxm=mean([xxx]);
parms(3)=xxxm(3);
parms(5)=xxxm(5);
parms(6)=xxxm(6);
parms(7)=xxxm(7);

parms2fit=[1 2 4];
parms1=parms; parms1(2)=3; plb1=plb;
xx1b=lsqnonlin(@linf,parms1(parms2fit),plb1(parms2fit),pub(parms2fit),opt6,parms,parms2fit,tti,yyi(:,1));
parms2=parms; parms2(2)=4; plb2=plb; %plb2(2)=xx1b(find(parms2fit==2))+1;
xx2b=lsqnonlin(@linf,parms2(parms2fit),plb2(parms2fit),pub(parms2fit),opt6,parms,parms2fit,tti,yyi(:,2));
parms4=parms; parms4(2)=6; plb4=plb; %plb4(2)=xx1b(find(parms2fit==2))+3;
xx4b=lsqnonlin(@linf,parms4(parms2fit),plb4(parms2fit),pub(parms2fit),opt6,parms,parms2fit,tti,yyi(:,3));
parms8=parms; parms8(2)=10; plb8=plb; %plb8(2)=xx1b(find(parms2fit==2))+7;
xx8b=lsqnonlin(@linf,parms8(parms2fit),plb8(parms2fit),pub(parms2fit),opt6,parms,parms2fit,tti,yyi(:,4));
%linf(parms,parms,parms2fit,tti,ad13i(:,2));
[bold1bi,uu1bi]=linf(xx1b,parms,parms2fit,tti);
[bold2bi,uu2bi]=linf(xx2b,parms,parms2fit,tti);
[bold4bi,uu4bi]=linf(xx4b,parms,parms2fit,tti);
[bold8bi,uu8bi]=linf(xx8b,parms,parms2fit,tti);
[bold8p2]=linf([xx8b(1) xx2b(2)+6 xx2b(3)],parms,parms2fit,tti);

xxxb=[xx1b;xx2b;xx4b;xx8b];

ttp=[ceil(tt(1)):floor(tt(end))];
yyp=interp1(tt',yy,ttp');
yyp1(:,1)=yyp(:,1);
yyp1(:,2)=yyp(:,1)+[yyp(end,1);yyp(1:end-1,1)];
yyp1(:,3)=yyp(:,1)+[yyp(end,1);yyp(1:end-1,1)]+[yyp(end-1:end,1);yyp(1:end-2,1)]+[yyp(end-2:end,1);yyp(1:end-3,1)];
yyp1(:,4)=yyp(:,1)+[yyp(end,1);yyp(1:end-1,1)]+[yyp(end-1:end,1);yyp(1:end-2,1)]+[yyp(end-2:end,1);yyp(1:end-3,1)];
yyp1(:,4)=yyp1(:,4)+[yyp(end-3:end,1);yyp(1:end-4,1)]+[yyp(end-4:end,1);yyp(1:end-5,1)];
yyp1(:,4)=yyp1(:,4)+[yyp(end-5:end,1);yyp(1:end-6,1)]+[yyp(end-6:end,1);yyp(1:end-7,1)];
yyp2(:,1)=yyp(:,2);
yyp2(:,2)=yyp(:,2)+[yyp(end-1:end,2);yyp(1:end-2,2)];
yyp2(:,3)=yyp(:,3)+[yyp(end-1:end,2);yyp(1:end-2,2)]+[yyp(end-3:end,2);yyp(1:end-4,2)]+[yyp(end-5:end,2);yyp(1:end-6,2)];


figure(1)
subplot(221)
plot(tt,yy(:,1),tti,bold1i)
subplot(222)
plot(tt,yy(:,2),tti,bold2i)
subplot(223)
plot(tt,yy(:,3),tti,bold4i)
subplot(224)
plot(tt,yy(:,4),tti,bold8i)

figure(2)
subplot(221)
plot(tt,yy(:,1),tti,bold1bi)
subplot(222)
plot(tt,yy(:,2),tti,bold2bi)
subplot(223)
plot(tt,yy(:,3),tti,bold4bi)
subplot(224)
plot(tt,yy(:,4),tti,bold8bi)

xEW=xxxb(:,2)-[1 2 4 8]';
xAMP=xxxb(:,3);
xAR=xEW.*xAMP;

figure(3)
subplot(232)
plot(tt-20,yy(:,3),tti-20,bold4bi)
%ylabel('BOLD')
xlabel('Time')
title('4s Visual Stimulus')
axis('tight'), grid('on'), ax=axis; axis([-5 ax(2:end)]);
fatlines, dofontsize(15);
subplot(231)
plot(tt-20,yy(:,2),tti-20,bold2bi)
ylabel('BOLD')
%xlabel('Time')
title('2s Visual Stimulus')
axis('tight'), grid('on'), ax=axis; axis([-5 ax(2:end)]);
fatlines, dofontsize(15);
subplot(233)
plot(tt-20,yy(:,4),tti-20,bold8bi)
%ylabel('BOLD')
%xlabel('Time')
title('8s Visual Stimulus')
axis('tight'), grid('on'), ax=axis; axis([-5 ax(2:end)]);
fatlines, dofontsize(15);
subplot(234)
plot([1 2 4 8],xEW)
%ylabel('Extra Width')
%xlabel('Stim. Duration')
axis('tight'), grid('on'),
fatlines, dofontsize(15);
subplot(235)
plot([1 2 4 8],xAMP)
%ylabel('Amplitude')
xlabel('Stim. Duration')
axis('tight'), grid('on'),
fatlines, dofontsize(15);
subplot(236)
plot([1 2 4 8],xAR)
%ylabel('Extra Area')
%xlabel('Stim. Duration')
axis('tight'), grid('on'),
fatlines, dofontsize(15);
%subplot(313)
%plot([1 2 4 8],xxxb(:,1)-xxxb(1,1))
%ylabel('Onset')
%plot([1 2 4 8],XAR)
%ylabel('Extra Area')
%xlabel('Stimulus Duration')

figure(4)
subplot(232)
plot(tt-20,yy(:,4),ttp-20,yyp2(:,3))
title('8s Predicted from 2s')
axis('tight'), grid('on'), ax=axis; axis([-5 ax(2:end)]);
fatlines, dofontsize(15);
subplot(222)
plot(tt-20,yy(:,4),ttp-20,yyp2(:,3)*0.522)
title('8s Predicted from 2s')
axis('tight'), grid('on'), ax=axis; axis([-5 ax(2:end)]);
fatlines, dofontsize(15);
legend('x 1','x 0.5')

