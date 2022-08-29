
clear all

cbf=[20:10:100]/100+1;
cbf=cbf(:);
m=0.1;
alpha=[0.4 0.2 0.0];
beta=[1.0 1.25 1.5 1.75];

cnt=0;
for mm=1:length(alpha),
  for nn=1:length(beta),
    cnt=cnt+1;
    aa(cnt)=alpha(mm);
    bb(cnt)=beta(nn);
    bold(:,cnt)=1+m*(1-cbf.^(alpha(mm)-beta(nn)));
  end;
end;

cbf2_base=1.3;
cbf2_std=0.05;
cbf2=randn(1,1000)*cbf2_std+cbf2_base;
bold2_base=1.03;
bold2_std=0.005;
bold2=randn(1,1000)*bold2_std+bold2_base;
m2=calcM(bold2,cbf2);
subplot(313)
hist(cbf2,50)
xlabel('CBF')
subplot(312)
hist(bold2,50)
xlabel('BOLD')
subplot(313)
hist(m2,50)
xlabel('M')

%plot(cbf,bold(:,[1 3 9 11]))
%plot(diff(bold(:,[1 3 9 11])))

bold_base=1.02;
bold_noise_std=[0.002:0.002:0.01];
cbf_base=1.5;
cbf_noise_std=[0.05:0.05:0.2];
m=[0.05:0.05:0.95];

for mm=1:length(bold_noise_std),
  for nn=1:length(cbf_noise_std),
    for oo=1:length(m),
      bold_noise=randn(1,1000)*bold_noise_std(mm)+1.02;
      cbf_noise=randn(1,1000)*cbf_noise_std(nn)+1.5;
      cmro2_noise=rcmro2(cbf_noise,bold_noise,m(oo));
      tmpcorr=corrcoef(cmro2_noise,cbf_noise);
      tmpcorr2=corrcoef(cmro2_noise,bold_noise);
      rcmro2_rcbf_noise(mm,nn,oo)=tmpcorr(1,2);
      rcmro2_bold_noise(mm,nn,oo)=tmpcorr2(1,2);
    end;
  end;
end;

figure(1),
tile3d(rcmro2_rcbf_noise)
title(sprintf('R (CMRO2-CBF) for F0= %1.2f (r:Fstd= %1.2f,%1.2f) vs. B0= %1.3f (c:Bstd= %1.3f,%1.3f)',cbf_base,cbf_noise_std(1),cbf_noise_std(end),bold_base,bold_noise_std(1),bold_noise_std(end)))
figure(2)
tile3d(rcmro2_bold_noise)
title(sprintf('R (CMRO2-BOLD) for F0= %1.2f (r:Fstd= %1.2f,%1.2f) vs. B0= %1.3f (c:Bstd= %1.3f,%1.3f)',cbf_base,cbf_noise_std(1),cbf_noise_std(end),bold_base,bold_noise_std(1),bold_noise_std(end)))
figure(3)
tmp1(:,1)=rcmro2_rcbf_noise(1,1,:);
tmp1(:,2)=rcmro2_rcbf_noise(1,4,:);
tmp1(:,3)=rcmro2_rcbf_noise(5,1,:);
tmp1(:,4)=rcmro2_rcbf_noise(5,4,:);
tmp2(:,1)=rcmro2_bold_noise(1,1,:);
tmp2(:,2)=rcmro2_bold_noise(1,4,:);
tmp2(:,3)=rcmro2_bold_noise(5,1,:);
tmp2(:,4)=rcmro2_bold_noise(5,4,:);
subplot(211)
plot(m,tmp1)
xlabel('M Factor')
ylabel('R (CMRO2-CBF)')
legend('Bstd=0.002 Fstd=0.05','Bstd=0.002 Fstd=0.2','Bstd=0.1 Fstd=0.05','Bstd=0.01 Fstd=0.2',4)
title(sprintf('F0= %1.2f (Fstd= %1.2f,%1.2f) B0= %1.3f (Bstd= %1.3f,%1.3f)',cbf_base,cbf_noise_std(1),cbf_noise_std(end),bold_base,bold_noise_std(1),bold_noise_std(end)))
fatlines; grid('on'); axis('tight'); 
subplot(212)
plot(m,tmp2)
legend('Bstd=0.002 Fstd=0.05','Bstd=0.002 Fstd=0.2','Bstd=0.1 Fstd=0.05','Bstd=0.01 Fstd=0.2',4)
xlabel('M Factor')
ylabel('R (CMRO2-BOLD)')
fatlines; grid('on'); axis('tight');

figure(1), print -dpng fig1_1
figure(2), print -dpng fig1_2
figure(3), print -dpng fig1_3

