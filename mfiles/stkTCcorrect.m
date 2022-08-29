function y=stkTCcorrect(fname,parms1,parms2,maskA,maskD)
% Usage ... y=stkTCcorrect(fname,parms1,parms2,mask,maskD)
%
% parms1=[ntr nimpertr noff drange(2 2)]
% parms2=[nblk nf nfw pord2 dt]


%eval(sprintf('load %s maskA maskD',fname(1:end-4)));
nblk=parms2(1);
ntr=parms1(1); i1n=parms1(3);
nimspertr=parms1(2);
ii0=[parms1(4:5)]; ii9=[parms1(6:7)];	% [420:440],[130:150]
nf=parms2(2); nfw=parms2(3);
if length(parms2)==5, dt=parms2(5); else, dt=1; end;

% read all the data
found=0;
cnt=0; cnt2=1;
while(~found),
  tmpstk=tiffread2(fname,(cnt2-1)*nblk+1,cnt2*nblk);
  if length(tmpstk),
    disp(sprintf('  im blk #%d',(cnt2-1)*nblk));
    for mm=1:length(tmpstk),
      cnt=cnt+1;
      tmpim=double(tmpstk(mm).data); 
      avgtcG(cnt)=mean(mean(tmpim));
      avgtcD(cnt)=sum(sum(tmpim.*maskD));
      for nn=1:size(maskA,3),
        avgtcA(cnt,nn)=sum(sum(tmpim.*maskA(:,:,nn)));
      end;
    end;
    if mm==nblk, cnt2=cnt2+1; else, found=1; end;
    clear tmpstk
  else,
    found=1;
  end;
end;
for nn=1:size(maskA,3), avgtcA(:,nn)=avgtcA(:,nn)/sum(sum(maskA(:,:,nn))); end;
avgtcD=avgtcD(:)/sum(sum(maskD));
avgtcG=avgtcG(:);

% general detrend first
ii=[1:length(avgtcA)]';
for nn=1:size(maskA,3),
  tmpp=polyfit(avgtcD,avgtcA(:,nn),1);
  tmpd=polyval(tmpp,avgtcD);
  avgtcAd(:,nn)=avgtcA(:,nn)-tmpd+mean(tmpd);
  tmppg=polyfit(avgtcG,avgtcA(:,nn),1);
  tmpdg=polyval(tmpp,avgtcG);
  avgtcAg(:,nn)=avgtcA(:,nn)-tmpdg+mean(tmpdg);
  tmpp2=polyfit(ii,avgtcAd(:,nn),parms2(4));
  tmpd2=polyval(tmpp2,ii);
  avgtcAd2(:,nn)=avgtcAd(:,nn)-tmpd2+mean(tmpd2);
  tmpd2fit(:,nn)=tmpd2(:);
  tmpp1=polyfit(ii,avgtcA(:,nn),parms2(4));
  tmpd1=polyval(tmpp1,ii);
  avgtcAd1(:,nn)=avgtcA(:,nn)-tmpd1+mean(tmpd1);
  tmpd1fit(:,nn)=tmpd1(:);
end;

y.parms1=parms1;
y.parms2=parms2;
y.maskA=maskA;
y.maskD=maskD;

y.yA=avgtcA;
y.yD=avgtcD;
y.yG=avgtcG;
y.yAd=avgtcAd;
y.yAg=avgtcAg;

y.yAd2=avgtcAd2;
y.pfitAd2=tmpd2fit;

y.yAd1=avgtcAd1;
y.pfitAd1=tmpd1fit;

avgtcD_tr=reshape(avgtcD(i1n:i1n+ntr*nimspertr-1),nimspertr,ntr);
avgtcG_tr=reshape(avgtcG(i1n:i1n+ntr*nimspertr-1),nimspertr,ntr);
for nn=1:size(maskA,3),
  avgtcA_tr(:,:,nn)=reshape(avgtcA(i1n:i1n+ntr*nimspertr-1,nn),nimspertr,ntr);
  avgtcAd_tr(:,:,nn)=reshape(avgtcAd(i1n:i1n+ntr*nimspertr-1,nn),nimspertr,ntr);
  avgtcAd2_tr(:,:,nn)=reshape(avgtcAd2(i1n:i1n+ntr*nimspertr-1,nn),nimspertr,ntr);
  avgtcAd1_tr(:,:,nn)=reshape(avgtcAd1(i1n:i1n+ntr*nimspertr-1,nn),nimspertr,ntr);
  avgtcAg_tr(:,:,nn)=reshape(avgtcAg(i1n:i1n+ntr*nimspertr-1,nn),nimspertr,ntr);

  avgtcA_a(:,nn)=mean(avgtcA_tr(:,:,nn)')';
  avgtcA_a(:,nn)=tcdetrend(avgtcA_a(:,nn),1,[ii0([1 end]) ii9([1 end])]);
  avgtcA_an(:,nn)=avgtcA_a(:,nn)/mean(avgtcA_a(ii0,nn));
  avgtcA_af(:,nn)=fermi1d(avgtcA_a(:,nn),nf,nfw,1,dt);
  avgtcA_afn(:,nn)=avgtcA_af(:,nn)/mean(avgtcA_af(ii0,nn));
  avgtcAd_a(:,nn)=mean(avgtcAd_tr(:,:,nn)')';
  avgtcAd_a(:,nn)=tcdetrend(avgtcAd_a(:,nn),1,[ii0([1 end]) ii9([1 end])]);
  avgtcAd_an(:,nn)=avgtcAd_a(:,nn)/mean(avgtcAd_a(ii0,nn));
  avgtcAd_af(:,nn)=fermi1d(avgtcAd_a(:,nn),nf,nfw,1,dt);
  avgtcAd_afn(:,nn)=avgtcAd_af(:,nn)/mean(avgtcAd_af(ii0,nn));
  avgtcAd2_a(:,nn)=mean(avgtcAd2_tr(:,:,nn)')';
  avgtcAd2_a(:,nn)=tcdetrend(avgtcAd2_a(:,nn),1,[ii0([1 end]) ii9([1 end])]);
  avgtcAd2_an(:,nn)=avgtcAd2_a(:,nn)/mean(avgtcAd2_a(ii0,nn));
  avgtcAd2_af(:,nn)=fermi1d(avgtcAd2_a(:,nn),nf,nfw,1,dt);
  avgtcAd2_afn(:,nn)=avgtcAd2_af(:,nn)/mean(avgtcAd2_af(ii0,nn));
  avgtcAd1_a(:,nn)=mean(avgtcAd1_tr(:,:,nn)')';
  avgtcAd1_a(:,nn)=tcdetrend(avgtcAd1_a(:,nn),1,[ii0([1 end]) ii9([1 end])]);
  avgtcAd1_an(:,nn)=avgtcAd1_a(:,nn)/mean(avgtcAd1_a(ii0,nn));
  avgtcAd1_af(:,nn)=fermi1d(avgtcAd1_a(:,nn),nf,nfw,1,dt);
  avgtcAd1_afn(:,nn)=avgtcAd1_af(:,nn)/mean(avgtcAd1_af(ii0,nn));

  avgtcAg_a(:,nn)=mean(avgtcAg_tr(:,:,nn)')';
  avgtcAg_a(:,nn)=tcdetrend(avgtcAg_a(:,nn),1,[ii0([1 end]) ii9([1 end])]);
  avgtcAg_an(:,nn)=avgtcAg_a(:,nn)/mean(avgtcAg_a(ii0,nn));
  avgtcAg_af(:,nn)=fermi1d(avgtcAg_a(:,nn),nf,nfw,1,dt);
  avgtcAg_afn(:,nn)=avgtcAg_af(:,nn)/mean(avgtcAg_af(ii0,nn));
end;

y.yA_tr=avgtcA_tr;
y.yAd_tr=avgtcAd_tr;
y.yAd2_tr=avgtcAd2_tr;
y.yAd1_tr=avgtcAd1_tr;

y.yA_a.a=avgtcA_a;
y.yA_a.f=avgtcA_af;
y.yA_a.n=avgtcA_an;
y.yA_a.fn=avgtcA_afn;
y.yAd2_a.a=avgtcAd2_a;
y.yAd2_a.f=avgtcAd2_af;
y.yAd2_a.n=avgtcAd2_an;
y.yAd2_a.fn=avgtcAd2_afn;

y.yAg_tr=avgtcAg_tr;
y.yAg_a.a=avgtcAg_a;
y.yAg_a.f=avgtcAg_af;
y.yAg_a.n=avgtcAg_an;
y.yAg_a.fn=avgtcAg_afn;

%eval(sprintf('save %s -append avgtcA* avgtcD* ttA',fname(1:end-4)));



