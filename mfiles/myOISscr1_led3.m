function myOISscr1_led3(fname,saveid,parms,ledOrd_orig)
% Usage ... myOISscr1_led3(fname,saveid,parms,ledOrd)
%
% parms=[fps nimtr ntr noff nkeep]

if iscell(fname),
  nims=fname{2};
  nled=fname{3};
  myOISscr1_new(fname{1},saveid,'do_load',[1:nims],'do_sequential',nled);
end;

if nargin<4, ledOrd_orig=[]; end;
if nargin<3, parms=[]; end;

if isempty(parms), parms=1; end;
parms_orig=parms;

if isempty(ledOrd_orig),
  eval(sprintf('load %s_res avgim_seq',saveid));
  displ(sprintf('load %s_res avgim_seq',saveid));
  figure(1), clf, showmany(avgim_seq), drawnow,
  ledOrd_orig=input('  enter ledOrd with brackets (eg, [3 1 2]): ');
end;

eval(sprintf('load %s_res',saveid));

if sum((ledOrd_orig-[1:length(ledOrd_orig)]).^2)>100*eps,
  tmpdata=data;
  data=tmpdata(:,:,ledOrd_orig,:);
  figure(1), clf, showmany(data(:,:,:,10)), drawnow,
  clear tmpdata
end;

nled=size(data,3);

%showMovie(squeeze(data(:,:,1,:)))
%showMovie(squeeze(data(:,:,1,:)),mean(data(:,:,1,10:100),4),[-1 1]*40)

for mm=1:nled, xx_motc{mm}=imMotDetect(squeeze(data(:,:,mm,:)),10,[4 20 1 1 0]); end;
figure(2), clf, plot(xx_motc{1}), drawnow


data_raw=data;
for mm=1:nled, 
    xx_motc{mm}(1,:)=xx_motc{mm}(2,:);
    data(:,:,mm,:)=imMotApply(xx_motc{mm},squeeze(data_raw(:,:,mm,:))); 
end;
avgim_seq=mean(data_raw,4);
stdim_seq=std(data_raw,[],4);
avgtc_seq=squeeze(mean(mean(data_raw,1),2));
avgim_motc=mean(data,4);
stdim_motc=std(data,[],4);
avgtc_motc=squeeze(mean(mean(data,1),2));

figure(3), clf, showmany(stdim_seq)
figure(4), clf, showmany(stdim_motc)

if isempty(refidname),
  refname='';
else,
  refname=sprintf('%s_res',refidname); 
end;

if ~strcmp(refname,sname),
  avgim_orig=avgim_seq;
  eval(sprintf('load %s mask* avgim_seq',refname));
  avgim_ref=avgim_seq;
  avgim_seq=avgim_orig;
else,
  mask=selectMask(data_raw(:,:,1,10));
  maskV=selectMask(data_raw(:,:,1,10));
  mask_reg=selectMask(data_raw(:,:,1,10));
  
  maskMN=manySubMasks(mask==1,20,12,maskV);
end;

figure(5), clf, im_overlay4(data(:,:,1,10),maskV+mask_reg), drawnow,

mask_reg_tc=getStkMaskTC(data,bwlabel(mask_reg>0));
for mm=1:nled,
  if iscell(xx_motc)&(length(xx_motc)>1),
    [data(:,:,mm,:),xx_intc(mm)]=imMotReg(squeeze(data(:,:,mm,:)),xx_motc{mm},1,zscore(mask_reg_tc.atc(:,:,mm)));
    %[data(:,:,mm,:),xx_intc(mm)]=imMotReg(squeeze(data(:,:,mm,:)),xx_motc{mm},0,zscore(mask_reg_tc.atc(:,:,mm)));
  else,
    [data(:,:,mm,:),xx_intc(mm)]=imMotReg(squeeze(data(:,:,mm,:)),[],0,zscore(mask_reg_tc.atc(:,:,mm))); 
  end;
end;
avgim_intc=mean(data,4);
stdim_intc=std(data,[],4);
avgtc_intc=squeeze(mean(mean(data,1),2))';

figure(6), clf, showmany(stdim_intc),

fps_actual=parms_orig(1);
fps=parms_orig(1)/nled;

do_average=0;
if length(parms)>1,
  do_average=1;
  ntr=parms_orig(2); nimtr=parms_orig(3); noff=parms_orig(4); nkeep=parms_orig(5);
end;

if do_average,
map_thr={{'x0.5',[4]},{'n0.5',[4]},{'n0.5',[4]}};
for mm=1:nled,
  %map_raw(mm)=myOISmap1(squeeze(data_raw(:,:,mm,:)),[ntr nimtr noff-nkeep],map_thr{mm}(1:2),[1 map_thr{mm}(3)]);
  %map(mm)=myOISmap1(squeeze(data(:,:,mm,:)),[ntr nimtr noff-nkeep],map_thr{mm}(1:2),[1 map_thr{mm}(3)]);
  %map(mm)=myOISmap1b(squeeze(data(:,:,mm,:)),[ntr nimtr noff-nkeep],[20 nkeep+1 1],{'0.5x',[4 2000],mask==1});
  %if exist('data_raw','var'),
  %  map_raw(mm)=myOISmap1b(squeeze(data_raw(:,:,mm,:)),[ntr nimtr noff-nkeep],[20 nkeep+1 1],map_thr{mm});
  %end;
  map(mm)=myOISmap1b(squeeze(data(:,:,mm,:)),[ntr nimtr noff-nkeep],[20 nkeep+1 1],map_thr{mm});
end;

if ~exist('maskA','var'),
  maskA=im_thr2(im_smooth(mean(map(1).adata(:,:,52:60),3),1).*(mask>0),'x0.5',50);
  maskA=maskA.*(mask==1);
  clf, show(maskA),
end;

tcA=getStkMaskTC(data,maskA>0);
tcA_raw=getStkMaskTC(data_raw,maskA>0);
tcMN=getStkMaskTC(data,maskMN);

tcA.atc_a=squeeze(mean(reshape(tcA.atc([1:nimtr*ntr]+noff-nkeep,:),[nimtr ntr nled]),2));
tcA.atc_an=tcA.atc_a./(ones(nimtr,1)*mean(tcA.atc_a(1:nkeep-10,:),1));
for mm=1:size(tcMN.atc,2),
  tcMN.atc_a(:,mm,:)=squeeze(mean(reshape(tcMN.atc([1:nimtr*ntr]+noff-nkeep,mm,:),[nimtr ntr 1 nled]),2));
  tcMN.atc_an(:,mm,:)=squeeze(tcMN.atc_a(:,mm,:))./(ones(nimtr,1)*squeeze(mean(tcMN.atc_a(1:nkeep-10,mm,:),1))');
end;

tcA_raw.atc_a=squeeze(mean(reshape(tcA_raw.atc([1:nimtr*ntr]+noff-nkeep,:),[nimtr ntr nled]),2));
tcA_raw.atc_an=tcA_raw.atc_a./(ones(nimtr,1)*mean(tcA_raw.atc_a(1:nkeep-10,:),1));

tt=[1:size(tcA.atc,1)]/fps;
for mm=1:nled, 
  swMN{mm}=myDynCorr(zscore(tcMN.atc(:,:,mm)),5*fps,1*fps); 
  swMN{mm}.r_a=mean(reshape(swMN{mm}.r(:,:,[1:ntr*nimtr/(1*fps)]+(noff-nkeep)/fps),...
      [size(tcMN.atc,2),size(tcMN.atc,2),nimtr/(1*fps),ntr]),4);
end;

figure(7), clf, plotmany(tcA.atc_an), drawnow,
end;

disp(sprintf('save %s -v7.3',sname));
eval(sprintf('save %s -v7.3',sname));
