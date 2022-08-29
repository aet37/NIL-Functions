function y=myOISmap1(data,stim_parms,map_parms,thr_parms,do_adata)
% Usage ... y=myOISmap1(data,stim_parms,map_parms,thr_parms,adata_flag)
%
% stim_parms = [ntrials,nimtr,noff]
% act_parms = [nim_baseANDstim  nskp_TO_aim smooth]
% thr_parms = {thr,[mincthr maxcthr],mask}
% the baseline period will be the first nstim images
% the activation period will start at nskp 
%
% Ex. map1=myOISmap1b(data,[16 200 130],[20 30 1],{'x0.5',[2 400]});
%     map1=myOISmap1b(data,[16 200 130],[20 30],0.01);
%     map1=myOISmap1b(data(:,:,1,:),[ntr nimtr noff nkeep],[nkeep-10 nkeep+1 1],'x0.4');
%     myOISmap1b(map1)
%     showMap(map1)

data=squeeze(data);

do_figure=1;
do_applymask=0;
if ~exist('do_adata','var'), do_adata=0; end;

if nargin<4, thr_parms='x0.5'; end;
if nargin<3, map_parms=[20 30 1]; end;

% copy the parameters of a previous map to these data
if isstruct(stim_parms),
  stim_parms_orig=stim_parms;
  if ~isfield(stim_parms_orig,'stim_parms')&isfield(stim_parms_orig,'nimtr'),
    if ~isfield(stim_parms_orig,'nkeep'), stim_parms_orig.nkeep=0; end;
    if ~isfield(stim_parms_orig,'nsm'), stim_parms_orig.nsm=1; end;
    stim_parms_orig.stim_parms=[stim_parms_orig.ntr stim_parms_orig.nimtr stim_parms_orig.noff stim_parms_orig.nkeep];
    stim_parms_orig.map_parms=[stim_parms_orig.nstim stim_parms_orig.nkeep stim_parms_orig.nsm];
  end;    
  if ~isfield(stim_parms_orig,'thr_parms'), thr_parms=map_parms; else, thr_parms=stim_parms_orig.thr_parms; end;
  clear stim_parms map_parms
  stim_parms=stim_parms_orig.stim_parms;
  map_parms=stim_parms_orig.map_parms;
  if isfield(stim_parms_orig,'adata'), do_adata=1; end;
  if isfield(stim_parms_orig,'do_adata'), do_adata=stim_parms_orig.do_adata; end;
  if isfield(stim_parms_orig,'mask'),
    do_applymask=1;
    maskA=stim_parms_orig.mask; 
  end;
end;

ntr=stim_parms(1);
nimtr=stim_parms(2);
noff=stim_parms(3);
if length(stim_parms)==4, nkeep=stim_parms(4); else, nkeep=0; end;

nstim=map_parms(1);
nskp=map_parms(2);
if length(map_parms)>2, smw=map_parms(3); else, smw=0; end;

if iscell(thr_parms),
  thr1=thr_parms{1};
  if length(thr_parms)>1, thr2=thr_parms{2}; else, thr2=[]; end;
  if length(thr_parms)>2, mask=thr_parms{3}; else, mask=[]; end;
else,
  thr1=thr_parms;
  thr2=[];
  mask=[];
end;

if (~isempty(mask))&(~ischar(mask)),
  if prod(size(mask))==prod(size(data(:,:,1))),
    do_applymask=1;
  else,
    do_applymask=2;
  end;
end;

if ~isempty(mask),
  if ischar(mask),
    if strcmp(mask,'select'),
      do_applymask=0; mflag=2;
    elseif strcmp(mask,'draw'),
      do_applymask=0; mflag=1;
    elseif strcmp(mask,'pick'),
      do_applymask=0; mflag=3;
    else,
      do_applymask=0; mflag=3;
    end;
  end;
else,
  mflag=0;
end;  

if do_applymask==2,
  disp('  xferring mask');
  maskA=xferMask1(stim_parms_orig.maskA,stim_parms_orig.bim,data(:,:,1));
end;

noff=noff-1;
%cref_all=rect([1:size(data,3)],nstim,[0:ntr]*nimtr+noff-nkeep+nskp+round(nstim/2));
cref_all=rect([1:size(data,3)],nstim,[0:ntr-1]*nimtr+noff-nkeep+nskp+round(nstim/2));
rmap=OIS_corr2(data,cref_all(:));
tmap=r2t(rmap,nstim*ntr-1); %tmap=r2t(rmap,size(data,3)-1);
if max(rmap(:))<0.5, rthr=0.7*max(rmap(:)); else, rthr=0.5; end;
rtc=getStkMaskTC(data,rmap>rthr);

% individual maps
adatad=single(zeros(size(data,1),size(data,2),nimtr));
for mm=1:ntr,
  tmpbim(:,:,mm)=mean(data(:,:,[1:nstim]+(mm-1)*nimtr+noff-nkeep),3);
  tmpaim(:,:,mm)=mean(data(:,:,[1:nstim]+(mm-1)*nimtr+noff-nkeep+nskp),3);
  adatad = adatad + data(:,:,[1:nimtr]+(mm-1)*nimtr+noff-nkeep) - repmat(tmpbim(:,:,mm),[1 1 nimtr]);
end;
adatad=adatad/ntr;
adatad=adatad./repmat(mean(tmpbim,3),[1 1 nimtr]);
map_all=tmpaim./tmpbim-1;

% average map
adata=mean(reshape(data(:,:,[1:nimtr*ntr]+noff-nkeep),...
    size(data,1),size(data,2),nimtr,ntr),4);

bim_ii=[1:nstim-1];
aim_ii=nskp+[1:nstim-1];
bim=mean(adata(:,:,bim_ii),3);
aim=mean(adata(:,:,aim_ii),3);

map=(aim./bim-1);

if do_applymask==0,
  tmpim=map;
  if smw>1e-4, 
    disp(sprintf('  smoothing map by %.2f',smw));
    tmpim=im_smooth(tmpim,smw); 
  end;

  if (mflag==1)|(mflag==2),
    mask=selectMask(map);
    map=map.*mask;
  end;

  maskA=im_thr2(tmpim,thr1,thr2);
  maskA=maskA>0;
  maskA=bwlabel(maskA);
  
  if mflag==2,
    disp('  multiple regions found, select one...');
    clf, show(im_super(map,maskA>0,0.5)), drawnow;
    [tmpx,tmpy]=ginput(1); tmpx=round(tmpx); tmpy=round(tmpy);
    tmpsel=maskA(tmpy,tmpx);
    maskA=(maskA==tmpsel);
    disp(sprintf('  selected region %d, press enter...',tmpsel));
    clf, show(mask), drawnow, pause,
  end;

  for mm=1:size(adata,3), atc(mm)=sum(sum(adata(:,:,mm).*maskA)); end;
  atc=atc/sum(sum(maskA));
  atcn=atc/mean(atc(1:nstim))-1;

  cref=atcn;
  cmap=OIS_corr2(adata,cref);
  cref_box=zeros(size(adata,3),1); 
  cref_box([1:nstim]+nskp)=1;    
  cmap_box=OIS_corr2(adata,cref_box);
  
  cmask=im_thr2(cmap,0.5,2);
  for mm=1:size(adata,3), catc(mm)=sum(sum(adata(:,:,mm).*(cmask>0))); end;
  catc=catc/sum(sum(cmask));
  catcn=catc/mean(catc(1:nstim))-1;
  
else,
    % applymask so use previous mask
    mask=maskA;
    for mm=1:size(adata,3), atc(mm)=sum(sum(adata(:,:,mm).*mask)); end;
    atc=atc/sum(sum(mask));
    atcn=atc/mean(atc(1:nstim))-1;

    cref=atcn;
    cref_box=zeros(size(adata,3),1); 
    cref_box([1:nstim]+nskp)=1;    
    cmap_box=OIS_corr2(adata,cref_box);
end;

y.stim_parms=stim_parms;
y.map_parms=map_parms;
y.thr_parms=thr_parms;
y.bim=bim;
y.aim=aim;
y.map=map;
y.mask=maskA;
y.map_all=map_all;
y.cref=cref_all;
y.cmap=rmap;
y.tmap=tmap;
if do_adata, y.adata=adatad; end;
y.atc=atc;
y.atcn=atcn;
if exist('cmap_box','var'),
  y.cmapa_box=cmap_box;
  y.crefa=cref;
  y.cmapa=cmap;
end;
if exist('cmask','var'),
  y.cmask=cmask;
  y.catc=catc;
  y.catcn=catcn;
end;
if do_applymask,
  y.mask_applied=mask;
end;

if nargout==0, do_figure=1; end;

if do_figure,
  if ~isempty(thr_parms),
    figure(1), clf,
    if smw>1e-4, map_sm=im_smooth(map,smw); cmap_sm=im_smooth(rmap,smw); else, map_sm=map; cmap_sm=y.cmap; end;
    subplot(331), show(map_sm), xlabel('Map'),
    subplot(332), show(maskA), xlabel('Mask'),
    subplot(333), show(cmap_sm), xlabel(sprintf('Corr Map (rthr=%.3f)',rthr)),
    subplot(312), plot([1:length(atcn)],atcn,...
                          bim_ii,ones(size(bim_ii))*0.9*min(atcn),...
                          aim_ii,ones(size(aim_ii))*1.1*max(atcn)), axis tight, grid on,
                  ylabel('Avg. Amplitude'), fatlines(1.5);
    subplot(313), plot(zscore([cref_all(:) rtc.atc(:)])), axis tight, grid on,
                  ylabel('Amplitude (z-Score)'), legend('Ref','AvgTC r>thr'), fatlines(1.5), 
    drawnow,
    print -dpng tmp_map1
  else,
    clf, show(map),
  end;
  drawnow,
  if nargout==0,
    clear y
  end;
end;

