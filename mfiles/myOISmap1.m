function y=myOISmap1(data,parms,sparms,tparms)
% Usage ... y=myOISmap1(data,parms,sparms,tparms_or_mask_apply)
%
% parms = [ntrials,nimtr,noff]
% stim_parms = [nim_baseANDstim  nskp_TO_aim]
% tc_parms = [smw thr mincthr maxcthr maskflag]
% the baseline period will be the first nstim images
% the activation period will start at nskp 
%
% Ex. map1=myOISmap1(data,[16 200 130],[20 10],[1 -1e-3]);

data=squeeze(data);

do_figure=1;
do_applymask=0;
do_adata=1;

if nargin<4, tparms=[]; end;
if nargin<3, sparms=[]; end;

if isstruct(parms),
  if ~isempty(sparms),
    if ischar(sparms), if strcmp(sparms,'apply'),
      disp('  applying mask in map structure...');
      do_applymask=2;
    end; end;
  end;
  maps_orig=parms;
  sparms=parms.stim_parms;
  tparms=parms.tc_parms;
  pparms=parms.parms;
  parms=pparms;
end;

if length(tparms)>10,
  do_applymask=1; 
  maskA=tparms;
  tparms=[];
end;

if do_applymask==2,
  disp('  xferring mask');
  maskA=xferMask1(maps_orig.mask,maps_orig.bim,data(:,:,1));
end;

ntr=parms(1);
nimtr=parms(2);
noff=parms(3);
nstim=sparms(1);
nskp=sparms(2);

cref_all=rect([1:size(data,3)],nstim,[0:ntr]*nimtr+noff+nskp+round(nstim/2));
rmap=OIS_corr2(data,cref_all(:));
tmap=r2t(rmap,nstim*ntr-1); %tmap=r2t(rmap,size(data,3)-1);


% individual maps
adatad=single(zeros(size(data,1),size(data,2),nimtr));
for mm=1:ntr,
  tmpbim(:,:,mm)=mean(data(:,:,[1:nstim]+(mm-1)*nimtr+noff),3);
  tmpaim(:,:,mm)=mean(data(:,:,[1:nstim]+(mm-1)*nimtr+noff+nskp),3);
  adatad = adatad + data(:,:,[1:nimtr]+(mm-1)*nimtr+noff) - repmat(tmpbim(:,:,mm),[1 1 nimtr]);
end;
adatad=adatad/ntr;
adatad=adatad./repmat(mean(tmpbim,3),[1 1 nimtr]);
map_all=tmpaim./tmpbim-1;

% average map
adata=mean(reshape(data(:,:,[1:nimtr*ntr]+noff-1),...
    size(data,1),size(data,2),nimtr,ntr),4);

bim_ii=[1:nstim-1];
aim_ii=nskp+[1:nstim-1];
bim=mean(adata(:,:,bim_ii),3);
aim=mean(adata(:,:,aim_ii),3);

map=(aim./bim-1);

if do_applymask==0,
    tmpim=map;
    if length(tparms)==2,
      smw=tparms(1);
      athr(1)=tparms(2); 
      mflag=0;
    elseif length(tparms)==1,
      smw=0;
      athr(1)=tparms(1); 
      mflag=0;
    else,
      smw=tparms(1);
      athr=tparms(2:4);
      mflag=tparms(5);
    end;
 
    if smw>0, tmpim=im_smooth(tmpim,smw); end;
    if athr(1)<0, tmpim=-1*tmpim; end;
    
    if length(athr)==1,
      mask=tmpim>abs(athr(1));
    else,
      mask=im_thr2(tmpim,abs(athr(1)),athr(2:3));
      mask=mask>0;
      mask=bwlabel(mask);
      if max(mask(:))>1, mflag=3; end;
    end;
 
    if mflag==1,
        clf, show(map), drawnow,
        disp('  select mask...');
        maskB=roipoly;
        mask=mask.*maskB;
    elseif mflag==2,
        mask=selectMask(map);
    elseif mflag==3,
        disp('  multiple regions found, select one...');
        clf, show(im_super(map,mask>0,0.5)), drawnow;
        [tmpx,tmpy]=ginput(1); tmpx=round(tmpx); tmpy=round(tmpy);
        tmpsel=mask(tmpy,tmpx);
        mask=(mask==tmpsel);
        disp(sprintf('  selected region %d, press enter...',tmpsel));
        clf, show(mask), drawnow, pause,
    end;

    for mm=1:size(adata,3), atc(mm)=sum(sum(adata(:,:,mm).*mask)); end;
    atc=atc/sum(sum(mask));
    atcn=atc/mean(atc(1:nstim))-1;

    cref=atcn;
    cmap=OIS_corr2(adata,cref);
    cref_box=zeros(size(adata,3),1); 
    cref_box([1:nstim]+nskp)=1;    
    cmap_box=OIS_corr2(adata,cref_box);
    
    if length(athr)>1,
      tmpim=cmap;
      if smw>0, tmpim=im_smooth(tmpim,smw); end;
      cmask=im_thr2(tmpim,0.71*max(tmpim(:)),athr(2));
    
      for mm=1:size(adata,3), catc(mm)=sum(sum(adata(:,:,mm).*cmask)); end;
      catc=catc/sum(sum(cmask));
      catcn=catc/mean(catc(1:nstim))-1;
    end;
else,
    mask=maskA;
    for mm=1:size(adata,3), atc(mm)=sum(sum(adata(:,:,mm).*mask)); end;
    atc=atc/sum(sum(mask));
    atcn=atc/mean(atc(1:nstim))-1;

    cref=atcn;
    cref_box=zeros(size(adata,3),1); 
    cref_box([1:nstim]+nskp)=1;    
    cmap_box=OIS_corr2(adata,cref_box);
end;

y.parms=parms;
y.stim_parms=sparms;
y.tc_parms=tparms;
y.bim=bim;
y.aim=aim;
y.map=map;
y.map_all=map_all;
y.cref=cref_all;
y.cmap=rmap;
y.tmap=tmap;
if do_adata, y.adata=adatad; end;
if (~isempty(tparms))|do_applymask,
    y.mask=mask;
    y.atc=atc;
    y.atcn=atcn;
    y.cmapa_box=cmap_box;
    y.crefa=cref;
    y.cmapa=cmap;
    if exist('cmask','var'),
      y.cmask=cmask;
      y.catc=catc;
      y.catcn=catcn;
    end;
end;

if nargout==0, do_figure=1; end;

if do_figure,
  if ~isempty(tparms),
      clf,
      subplot(221), show(map), xlabel('Map'),
      subplot(222), show(mask), xlabel('Mask'),
      subplot(212), plot([1:length(atcn)],atcn,...
                          bim_ii,ones(size(bim_ii))*0.9*min(atcn),...
                          aim_ii,ones(size(aim_ii))*1.1*max(atcn)), ylabel('Avg. Amplitude'), 
      print -dpng tmp_map1
  else,
      clf, show(map)
  end;
  drawnow,
  if nargout==0,
      clear y
  end;
end;

