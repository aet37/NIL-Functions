
clear all
close all

do_save=1;
load biopac_data

varnames={{'dyn1wh1S','dyn1wh1S1','dyn1wh1S2','dyn1wh1S3'},
          {'dyn1l1p0dcS','dyn1l1p0dcS1','dyn1l1p0dcS1','dyn1l1p0dcS1'},
          {'dyn1l1p0dcSwh','dyn1l1p0dcS1wh','dyn1l1p0dcS2wh','dyn1l1p0dcS3wh'},
          {'dyn1l1p0aaSwh','dyn1l1p0aaS1wh','dyn1l1p0aaS2wh','dyn1l1p0aaS3wh'},
          {'dyn1l1p0aaSwhn50','dyn1l1p0aaS1whn50','dyn1l1p0aaS2whn50','dyn1l1p0aaS3whn50'},
          {'dyn1l1p0aaSwhn15','dyn1l1p0aaS1whn15','dyn1l1p0aaS2whn15','dyn1l1p0aaS3whn15'},
          {'dyn1l1p0aaSwhp15','dyn1l1p0aaS1whp15','dyn1l1p0aaS2whp15','dyn1l1p0aaS3whp15'},
          {'dyn1l1p0aaSwhp50','dyn1l1p0aaS1whp50','dyn1l1p0aaS2whp50','dyn1l1p0aaS3whp50'},
          };


for mm=1:length(varnames),
  for nn=2:length(varnames{mm}),
    eval(sprintf('%s_bio.tt=%s_new.tt;',varnames{mm}{1},varnames{mm}{2}));
    eval(sprintf('%s_bio.StimON_orig=%s_new.StimON_orig;',varnames{mm}{1},varnames{mm}{2}));
    eval(sprintf('%s_bio.vars{nn-1}=varnames{mm}{nn};',varnames{mm}{1}));
    eval(sprintf('%s_bio.varn(nn-1)=length(%s_new.HRavg);',varnames{mm}{1},varnames{mm}{nn}));
    eval(sprintf('tmpn=%s_bio.varn;',varnames{mm}{1}));
    if length(tmpn)==1,
      tmpii=[1:tmpn];
    else,
      tmpii=[sum(tmpn(1:end-1))+1:sum(tmpn)];
    end;
    disp(sprintf('  %s to %s (%d to %d)',varnames{mm}{1},varnames{mm}{nn},tmpii(1),tmpii(end)));
    %eval(sprintf('%s_bio.HRavg(tmpii)=%s_new.HRavg;',varnames{mm}{1},varnames{mm}{nn}));
    %eval(sprintf('%s_bio.HRstd(tmpii)=%s_new.HRstd;',varnames{mm}{1},varnames{mm}{nn}));
    eval(sprintf('%s_bio.FLUXbase(tmpii)=%s_new.FLUXbase;',varnames{mm}{1},varnames{mm}{nn}));
    eval(sprintf('%s_bio.TBbase(tmpii)=%s_new.TBbase;',varnames{mm}{1},varnames{mm}{nn}));
    eval(sprintf('%s_bio.FLUX(:,tmpii)=%s_new.FLUX;',varnames{mm}{1},varnames{mm}{nn}));
    eval(sprintf('%s_bio.TB(:,tmpii)=%s_new.TB;',varnames{mm}{1},varnames{mm}{nn}));
    eval(sprintf('%s_bio.ts=%s_new.flxtb.tt;',varnames{mm}{1},varnames{mm}{nn}));
    eval(sprintf('tmptt=%s_new.flxtb.tt;',varnames{mm}{nn})); 
    tmpi0=find((tmptt>-4)&(tmptt<-1)); tmpi9=find((tmptt>26)&(tmptt<29));
    eval(sprintf('tmpyy=%s_new.flxtb.flux;',varnames{mm}{nn}));
    tmpyy=tcdetrend(tmpyy,1,[tmpi0([1 end]) tmpi9([1 end])]); 
    tmpy0=mean(tmpyy(tmpi0,:),1); tmpyy=tmpyy./(ones(size(tmpyy,1),1)*tmpy0);
    tmpyy=myfilter1(tmpyy,2.5,tmptt(2)-tmptt(1));
    eval(sprintf('%s_bio.fluxs(:,tmpii)=tmpyy;',varnames{mm}{1}));
    eval(sprintf('tmpyy=%s_new.flxtb.tb;',varnames{mm}{nn}));
    tmpy0=mean(tmpyy(tmpi0,:),1); tmpyy=tmpyy./(ones(size(tmpyy,1),1)*tmpy0);
    tmpyy=myfilter1(tmpyy,2.5,tmptt(2)-tmptt(1));
    eval(sprintf('%s_bio.tbs(:,tmpii)=tmpyy;',varnames{mm}{1}));
    clear tmp*
  end;
end;

if do_save,
  save biopac_data -append *bio
end;


figure(1), clf,
subplot(211), plotmsd4(dyn1wh1S_bio.FLUX), title('dyn1wh1S'), subplot(212), plotmsd4(dyn1wh1S_bio.TB),
figure(2), clf,
subplot(211), plotmsd4(dyn1l1p0aaSwh_bio.FLUX), title('dyn1l1p0aaSwh'), subplot(212), plotmsd4(dyn1l1p0aaSwh_bio.TB),
figure(3), clf,
subplot(211), plotmsd4(dyn1l1p0dcSwh_bio.FLUX), title('dyn1l1p0dcS'), subplot(212), plotmsd4(dyn1l1p0dcSwh_bio.TB),
figure(4), clf,
subplot(211), plotmsd4(dyn1l1p0dcS_bio.FLUX), title('dyn1l1p0dcS'), subplot(212), plotmsd4(dyn1l1p0dcS_bio.TB),
figure(5), clf,
subplot(211), plotmsd4(dyn1l1p0aaSwhn50_bio.FLUX), title('dyn1l1p0aaSwhn50'), subplot(212), plotmsd4(dyn1l1p0aaSwhn50_bio.TB),
figure(6), clf,
subplot(211), plotmsd4(dyn1l1p0aaSwhn15_bio.FLUX), title('dyn1l1p0aaSwhn50'), subplot(212), plotmsd4(dyn1l1p0aaSwhn15_bio.TB),
figure(7), clf,
subplot(211), plotmsd4(dyn1l1p0aaSwhp15_bio.FLUX), title('dyn1l1p0aaSwhp15'), subplot(212), plotmsd4(dyn1l1p0aaSwhp15_bio.TB),
figure(8), clf,
subplot(211), plotmsd4(dyn1l1p0aaSwhp50_bio.FLUX), title('dyn1l1p0aaSwhp50'), subplot(212), plotmsd4(dyn1l1p0aaSwhp50_bio.TB),

