function y=scr_OISrest(fname,sname,parms,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11)
% Usage ... y=scr_OISrest(fname,sname,parms,opt1,opt2,opt3,...)


%fname='20140814mouse_gcamp_rest4.stk';
%sname='tmp_gcamp_rest4data';

ii=[22 493 165 624 1 3050];
load tmp_gcamp_rest1data ii maskD


nbin=2;
nblk=1;
arima_coeffs=[15 1 1];
dord=2;
fco=0.15;
fco2=0.20;
fps=10;

do_choosecrop=0;
do_readdata=1;
do_motc=1;
do_intc=0;
do_masksub=1;
do_globalmean=0;
do_ar=1;
do_arima=0;
do_detrend=0;
do_filter=1;
do_filter2=1;
do_sellocs=0;
do_corr=0;
do_showcorr=0;
do_save=1;


if do_choosecrop,
  show(readOIS3(fname)),
  disp('  select the two cropping rectangular corners...')
  tmpi=round(ginput(2));
  ii=[tmpi(1,2) tmpi(2,2) tmpi(1,1) tmpi(2,1) ii(5:6)];
  ii(2)=ii(2)-rem(ii(2)-ii(1)+1,nbin);
  ii(4)=ii(4)-rem(ii(4)-ii(3)+1,nbin);
  ii,
end;

if (do_masksub)&(~exist('maskD')),
  tmpim=readOIS3(fname);
  tmpim=imbin(tmpim(ii(1):ii(2),ii(3):ii(4)),nbin)/nbin;
  show(tmpim),
  disp('  select bone mask for regression...')
  maskD=roipoly;
  show(im_super(tmpim,maskD,0.5)), drawnow,
end;


if (do_readdata),
  stk=zeros(floor((ii(2)-ii(1)+1)/nbin),floor((ii(4)-ii(3)+1)/nbin),floor((ii(6)-ii(5)+1)/nblk));
  found=0; cnt=0;
  while(~found),
    cnt=cnt+1;
    disp(sprintf('  reading %02d: %d to %d',cnt,(ii(5)-1+cnt-1)*nblk+1,(ii(5)-1+cnt)*nblk));
    tmpstk=readOIS3(fname,[(ii(5)-1+cnt-1)*nblk+1:(ii(5)-1+cnt)*nblk]);
    for mm=1:size(tmpstk,3),
      tmpstk2(:,:,mm)=imbin(tmpstk(ii(1):ii(2),ii(3):ii(4),mm),nbin)/nbin;
    end;
    stk(:,:,cnt)=mean(tmpstk2,3);
    if length(ii)>4,
      if ((ii(5)+cnt)*nblk)>ii(6), found=1; end;
    end;
  end;
  if do_motc,
    [xx_mc,stk_mc]=imMotDetect(stk,1,[4 20 0 1 0]);
    stk=stk_mc;
    clear stk_mc
  end;
  clear tmp*
  if do_save,
    eval(sprintf('save %s',sname)); 
  end;
else,
  eval(sprintf('load %s',sname));
end;

if (do_masksub),
  if ~exist('maskD'),
    clf, show(stk(:,:,1)), drawnow,
    disp(sprintf('select mask...'));
    maskD=roipoly;
  end;
  figure(1), clf, show(im_super(stk(:,:,1),maskD,0.5)), drawnow,
  avgimtc=squeeze(mean(mean(stk,1),2));
  maskDi=find(maskD);
  stk2=stk;
  for mm=1:size(stk,3),
    tmpim=stk2(:,:,mm);
    avgtcD(mm)=mean(tmpim(maskDi));
  end;
  figure(2), clf, plot([avgtcD(:) avgimtc(:)]), legend('mask','im dc'), drawnow,
  disp(sprintf('  removing mask contributions from pixel time series...'));
  stk_maskp=zeros(size(stk,1),size(stk,2),2);
  for mm=1:size(stk,1), for nn=1:size(stk,2),
    tmptc=squeeze(stk2(mm,nn,:));
    tmpp=polyfit(avgtcD(:),tmptc(:),1);
    tmpv=polyval(tmpp,avgtcD(:));
    tmptcf=tmptc(:)-tmpv(:)+mean(tmpv(:));
    stk2(mm,nn,:)=tmptcf;
    stk_maskp(mm,nn,:)=tmpp;
  end; end;
else,
  stk2=stk;
end;

if do_intc,
  tmpreg(:,1)=fermi1d(xx_mc(:,1),0.25*fps/nblk,0.05*fps/nblk,1,nblk/fps);
  tmpreg(:,2)=fermi1d(xx_mc(:,2),0.25*fps/nblk,0.05*fps/nblk,1,nblk/fps);
  tmpreg(:,3)=(tmpreg(:,1)-mean(tmpreg(:,1))).^2;
  tmpreg(:,4)=(tmpreg(:,2)-mean(tmpreg(:,2))).^2;
  tmpreg(:,5)=(tmpreg(:,1)-mean(tmpreg(:,1))).*(tmpreg(:,2)-mean(tmpreg(:,2)));
  tmplog(:,1)=log(tmpreg(:,1))-mean(log(tmpreg(:,1)));
  tmplog(:,2)=log(tmpreg(:,2))-mean(log(tmpreg(:,2)));
  if isempty(find(isinf(tmplog)))&isempty(find(isreal(tmplog)==0)),
    disp('  adding log to regressors');
    tmpreg(:,6)=tmplog(:,1); tmpreg(:,7)=tmplog(:,2);
  end;
  stk_ic=zeros(size(stk2));
  stk_icp=zeros(size(stk2,1),size(stk2,2),size(tmpreg,2)+1);
  for nn=1:size(stk2,1),
    tmp1=mreg(tmpreg,squeeze(stk2(nn,:,:))',1);
    stk_icp(nn,:,:)=tmp1.b';
    stk_ic(nn,:,:)=tmp1.yf';
  end;
  ic_reg=tmpreg;
  clear tmp*
  stk2=stk_ic;
  clear stk_ic
end;

if do_globalmean,
  disp(sprintf('  removing global mean contributions from pixel time series...'));
  stk_gmeanp=zeros(size(stk,1),size(stk,2),2);
  for mm=1:size(stk,1), for nn=1:size(stk,2),
    tmptc=squeeze(stk2(mm,nn,:));
    tmpp=polyfit(avgimtc(:),tmptc(:),1);
    tmpv=polyval(tmpp,avgimtc(:));
    tmptcf=tmptc(:)-tmpv(:)+mean(tmpv(:));
    stk2(mm,nn,:)=tmptcf;
    stk_gmeanp(mm,nn,:)=tmpp;
  end; end;
end;

if do_detrend,
  disp(sprintf('  detrending time series...'));
  tlen=size(stk,3);
  for mm=1:size(stk,1), for nn=1:size(stk,2),
    tmptc=squeeze(stk2(mm,nn,:));
    tmptc=tcdetrend(tmptc(:),dord,[1 tlen]);
    stk2(mm,nn,:)=tmptc;
  end; end;
end;

stk_aim=mean(stk,3);
stk2_aim=mean(stk2,3);

if do_ar,
  ncoeffs=arima_coeffs(1);
  stk_arp=zeros(size(stk,1),size(stk,2),ncoeffs+1);
  stk_ar=zeros(size(stk2));
  for mm=1:size(stk,1), for nn=1:size(stk,2),
    tmptc=squeeze(stk2(mm,nn,:));
    tmpar=aryule(tmptc-mean(tmptc),ncoeffs);
    tmptcf=filter(tmpar,1,tmptc-mean(tmptc));
    tmptc=tmptcf+mean(tmptc);
    stk_ar(mm,nn,:)=tmptc;
    stk_arp(mm,nn,:)=tmpar;
  end; end;
  stk_ar_aim=mean(stk_ar,3);
end;

if do_arima,
  ncoeffs=arima_coeffs;
  stk_arima=zeros(size(stk,1),size(stk,2),size(stk,3)-ncoeffs(2));
  for mm=1:size(stk,1), for nn=1:size(stk,2), 
    tmptc=squeeze(stk2(mm,nn,:)); 
    tmptcf=apostolos_arima(tmptc,ncoeffs);
    stk_arima(mm,nn,:)=tmptcf;
  end; end; 
  clear tmp*
  %stk2=stk_arima; clear stk_arima    
end;

if do_filter,
  stk_filt=stk2;
  disp(sprintf('  filtering data to %.2f...',fco));
  for mm=1:size(stk,1), for nn=1:size(stk,2),
    tmptc=squeeze(stk2(mm,nn,:));
    tmptcf=real(myfilter(tmptc,fco,nblk/fps));
    stk_filt(mm,nn,:)=tmptcf;
  end; end;
  stk_filt_aim=mean(stk_filt,3);
end;

if do_filter2,
  stk_filt2=stk2;
  disp(sprintf('  filtering(2) data to %.2f...',fco2));
  for mm=1:size(stk,1), for nn=1:size(stk,2),
    tmptc=squeeze(stk2(mm,nn,:));
    %tmptcf=real(myfilter(tmptc,fco,nblk/fps));
    tmptcf=fermi1d(tmptc,[0.03 0.2],[0.01 0.05],[-1 1],nblk/fps);
    stk_filt2(mm,nn,:)=tmptcf;
  end; end;
  stk_filt2_aim=mean(stk_filt2,3);
end;


if do_save, 
  clear tmp*
  eval(sprintf('save %s',sname)); 
end;

return,


% movies of tmpims
for mm=1:size(stk2,3), show(im_smooth(stk2(:,:,mm)-stk2_aim,1),[-1 1]*30), xlabel(num2str(mm)), drawnow, end
for mm=1:size(stk2,3), show(im_smooth(stk_ar(:,:,mm)-stk_ar_aim,1),[-1 1]*30), xlabel(num2str(mm)), drawnow, end
for mm=1:size(stk2,3), show(im_smooth(stk_filt(:,:,mm)-stk_filt_aim,1),[-1 1]*30), xlabel(num2str(mm)), drawnow, end

% save tmpims
for mm=1:size(stk2,3), tmpim=imwlevel(im_smooth(stk2(:,:,mm)-stk2_aim,1),[-1 1]*30,1); imwrite(tmpim,sprintf('tmp/tmpim_%05d.jpg',mm)); end;
for mm=1:size(stk2,3), tmpim=imwlevel(im_smooth(stk_ar(:,:,mm)-stk_ar_aim,1),[-1 1]*30,1); imwrite(tmpim,sprintf('tmp/tmpim_%05d.jpg',mm)); end;
for mm=1:size(stk2,3), tmpim=imwlevel(im_smooth(stk_filt(:,:,mm)-stk_filt_aim,1),[-1 1]*30,1); imwrite(tmpim,sprintf('tmp/tmpim_%05d.jpg',mm)); end;

% calculate k-means
for mm=1:size(stk,3), tmpstk(:,:,mm)=imbin(stk_ar(1:172,1:164,mm),4)/4; end;
tmplabel=reshape([1:size(tmpstk,1)*size(tmpstk,2)],size(tmpstk,1),size(tmpstk,2));
tmpk=mykmeans(reshape(tmpstk,size(tmpstk,1)*size(tmpstk,2),size(tmpstk,3))',2:20,tmplabel);
tmpks=mykmeans_sup(tmpk,tmpstk,tmplabel,1.5);
im_overlay4(tmpstk(:,:,1),sum(tmpk{19}.klim,3))
imagesc(sum(tmpk{19}.klim,3)), colormap('jet'),

addpath('/Users/towi/matlab/fastICA_25')
tmpica_1=fastica(reshape(tmpstk-repmat(mean(tmpstk,3),[1 1 size(tmpstk,3)]),size(tmpstk,1)*size(tmpstk,2),size(tmpstk,3)),'numOfIC',20);
tmpica_2=fastica(reshape(tmpstk-repmat(mean(tmpstk,3),[1 1 size(tmpstk,3)]),size(tmpstk,1)*size(tmpstk,2),size(tmpstk,3))','numOfIC',20);
for mm=1:size(tmpica_1,1), tmpica_1_cor(:,:,mm)=OIS_corr2(tmpstk,tmpica_1(mm,:)'); end;
tmpica_2_map=reshape(tmpica_2',size(tmpstk,1),size(tmpstk,2),size(tmpica_2,1));
show(reshape(tmpica_2(1,:),size(tmpstk,1),size(tmpstk,2)))

[tmppca_1,tmppca_1e,tmppca_1w]=svd( reshape(tmpstk-repmat(mean(tmpstk,3),[1 1 size(tmpstk,3)]),size(tmpstk,1)*size(tmpstk,2),size(tmpstk,3)) );
%[tmppca_1,tmppca_1e,tmppca_1w]=svd( reshape(tmpstk,size(tmpstk,1)*size(tmpstk,2),size(tmpstk,3)) );
[tmppca_2,tmppca_2e,tmppca_2w]=svd( reshape(tmpstk-repmat(mean(tmpstk,3),[1 1 size(tmpstk,3)]),size(tmpstk,1)*size(tmpstk,2),size(tmpstk,3))' );
%[tmppca_2,tmppca_2e,tmppca_2w]=svd( reshape(tmpstk,size(tmpstk,1)*size(tmpstk,2),size(tmpstk,3))' );
plot(diag(tmppca_1e))
show(reshape(tmppca_1(:,1),size(tmpstk,1),size(tmpstk,2)))




if do_sellocs,
  clf, show(stk2(:,:,1)), drawnow,
  locs=round(ginput);
  im_overlay4(stk2(:,:,1),pixtoim([locs(:,2) locs(:,1)],size(stk2(:,:,1))));
  drawnow;
  eval(sprintf('save %s -append locs',sname));
else,
  eval(sprintf('load %s locs',sname));
end;

if do_corr,
  for mm=1:size(locs,1),
    refs(:,mm)=squeeze(stk2(locs(mm,2),locs(mm,1),:));
  end;
  for mm=1:size(refs,2),
    corr(:,:,mm)=OIS_corr2(stk2(:,:,401:1001),refs(401:1001,mm));
  end;
  for mm=1:size(stk2,3),
    refsA(mm,1)=sum(sum(stk2(:,:,mm).*mask_ois620_lFLc));
    refsA(mm,2)=sum(sum(stk2(:,:,mm).*mask_ois620_rFLc));
  end;
  refsA(:,1)=refsA(:,1)/sum(sum(mask_ois620_lFLc));
  refsA(:,2)=refsA(:,2)/sum(sum(mask_ois620_rFLc));
  corrA(:,:,1)=OIS_corr2(stk2(:,:,401:end),refsA(401:end,1));
  corrA(:,:,2)=OIS_corr2(stk2(:,:,401:end),refsA(401:end,2));
end;

if do_showcorr,
  close all,
  figure(1),
  setpapersize([8 10]);
  for mm=1:size(corr,3),
    subplot(211)
    show(im_super(stk(:,:,1),imdilate(pixtoim([locs(mm,2),locs(mm,1)],[size(stk,1) size(stk,2)]),ones(3,3)),1)')
    subplot(212)
    %show(corr(:,:,mm)',[-1 1])
    %show(im_smooth(corr(:,:,mm),0.8)'>0.71)
    show(corr(:,:,mm)')
    xlabel(sprintf('%02d',mm));
    drawnow,
    %eval(sprintf('print -dpng %s_c%02dfig',sname,mm))
    pause,
  end;
end;

