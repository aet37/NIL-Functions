%% Start clean
%

clear all
close all


%% Define Object
%

tt=[0:249];
s1=15*sin(2*pi*0.032*tt(:));
s2=10*sin(2*pi*0.041*tt(:));

s1n = 5 + s1 + 0.1*randn(size(s1));
s2n = 3 + s2 + 0.1*randn(size(s2));

loc1=[20 14];
loc2=[32 35];

figure(1), clf,
subplot(311), plot(tt,s1), axis tight, grid on, ylabel('S1'),
subplot(312), plot(tt,s2), axis tight, grid on, ylabel('S2'),
subplot(313), plot(tt,s1n,tt,s2n), axis tight, grid on, legend('S1','S2'),

data=randn(100,100,250);
data(loc1(1)+[1:40],loc1(2)+[1:40],:)=data(loc1(1)+[1:40],loc1(2)+[1:40],:) + ...
    permute(repmat(s1n(:),[1 40 40]),[2 3 1]);
data(loc2(1)+[1:40],loc2(2)+[1:40],:)=data(loc2(1)+[1:40],loc2(2)+[1:40],:) + ...
    permute(repmat(s2n(:),[1 40 40]),[2 3 1]);

datasz=size(data);
avgim=mean(data,3);
stdim=std(data,[],3);

figure(2), clf,
showMovie(data,[],[-1 1]*30),


%% Define masks
%

maskA=[];
tmpmask=zeros(datasz(1:2));
tmpmask(find(avgim>2))=1;
maskA(:,:,1)=tmpmask;

tmpmask=zeros(datasz(1:2));
tmpmask(find(avgim>4))=1;
maskA(:,:,2)=tmpmask;

tmpmask=zeros(datasz(1:2));
tmpmask(find(avgim>6))=1;
maskA(:,:,3)=tmpmask;

maskA(:,:,4)=maskA(:,:,1)&(~maskA(:,:,2));
maskA(:,:,5)=maskA(:,:,2)&(~maskA(:,:,3));
maskA(:,:,6)=maskA(:,:,3)|maskA(:,:,4);

figure(2), clf,
showmany(maskA);

tcA=getStkMaskTC(data,maskA);

figure(3), clf,
plotmany(tt,tcA.atc),


%% Prep analysis
%

mypca=mypcadecomp(data,20,[],0,1);
myica=myICAdecomp(data,20,[],1,1);
%myica2=myICAdecomp(dataz,20,[],0,1);


%% Show PCA results
%

figure(4), clf,
tile3d(OIS_corr2(data,[s1 s2]),[],1), colormap jet,
xlabel('Correlation with S1 and S2'),

figure(5), clf,
plotmany(mypca.pca(:,1:12))

figure(6), clf,
showmany(reshape(mypca.pca_w(1:12,:)',[size(data,1) size(data,2) 12]))



%% Show fastICA results
%
figure(7), clf,
plotmany(myica.ica_A(:,1:12)),

figure(8), clf,
showmany(reshape(myica.ica(1:12,:)',[size(data,1) size(data,2) 12])),

%figure(7), clf,
%plotmany(myica2.ica(1:12,:)')
%
%figure(8), clf,
%showmany(reshape(myica2.ica_A(:,1:12),[size(data,1) size(data,2) 12])),

