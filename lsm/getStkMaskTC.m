function y=getStkMaskTC(stk,mask,norm,dparms,fparms,sparms)
% Usage ... y=getStkMaskTC(stk,mask,norm_or_#ims,dparms,fparms,sparms)
%
% Get time series from STK based on Mask
% Use range in norm for normalization
% dparms=[dord drange]
% fparms=[fco fw];
% sparms=[ntrials nimtr noff nkeep]
%
% Ex. tcA=getStkMaskTC(data,maskA,[1:20],[],[],[ntr nimtr noff nkeep]);
%     tcA=getStkMaskTC(data,maskA,'mode');

if ~exist('sparms','var'), sparms=[]; end;
if ~exist('fparms','var'), fparms=[]; end;
if ~exist('dparms','var'), dparms=[]; end;
if ~exist('norm','var'), norm=[]; end;

if ~isempty(sparms),
  if length(sparms)<4, sparms(4)=0; end;
end;

do_readfile=0;
if ischar(stk),
  do_readfile=1; 
  if strcmp(stk(end),'/'),
    do_readfile=3;
  %elseif strcmp(stk(end-3:end),'.tif'),
  %  do_readfile=3;
  elseif strcmp(stk(end-3:end),'.raw'),
    do_readfile=2;
  end;
end;

do_norm=1; do_det=1; do_filt=1; do_avg=1;
if isempty(norm), do_norm=0; end;
if isempty(dparms), do_det=0; end;
if isempty(fparms), do_filt=0; end;
if isempty(sparms), do_avg=0; end;

if iscell(mask),
  for mm=1:length(mask),
    tmpmask(:,:,mm)=int16(mask{mm});
  end;
  clear mask
  mask=tmpmask;
  clear tmpmask
  %size(mask),
end;

if ischar(norm), 
    if strcmp(norm,'mode'), 
        do_norm=2; 
    end; 
end;

if (size(mask,3)>1),
  if max(max(sum(mask,3)))>1,
    do_manymasks=1;
  else,
    do_manymasks=0;
  end;
  if ~do_manymasks,
    tmpmask=uint16(mask(:,:,1));
    for mm=2:size(mask,3),
       tmpmask(find(mask(:,:,mm)))=mm;
    end;
    clear mask
    mask=tmpmask;
    clf, imagesc(mask), axis image, colorbar, drawnow,
  end;
else,
  do_manymasks=0;
end;

if do_manymasks,
  maskn=size(mask,3);
  nmaskn=sum(mask(:)>10*eps);
  for mm=1:maskn,
    tmpmaski{mm}=find(mask(:,:,mm)>10*eps);
    nmaski(mm)=1; %nmaski(mm)=length(tmpmaski{mm});
  end;
else,
  tmpcnt=0; nmaski=[];
  for mm=1:max(double(mask(:))),
    tmpi=find(mask==mm);
    if ~isempty(tmpi),
      tmpcnt=tmpcnt+1;
      nmaski(tmpcnt)=mm;
    end;
  end;
  maskn=tmpcnt;
  for nn=1:maskn,
    tmpmaski{nn}=find(mask==nmaski(nn));
  end;
end;

%maskn=max(double(mask(:)));
if do_readfile==1,
  fname=stk; clear stk
  tmpinfo=imfinfo(fname);
  stkdim(1:2)=[tmpinfo.Width tmpinfo.Height];
  stkdim(3)=length(tmpinfo.UnknownTags(3).Value);
  disp(sprintf('  stk dim= %d %d %d',stkdim(1),stkdim(2),stkdim(3)));
elseif do_readfile==2,
  fname=stk; clear stk
  [tmpim,tmp2,tmpinfo]=readOIS(fname);
  stkdim=[size(tmpim,1) size(tmpim,2) tmpinfo.nfr];
  disp(sprintf('  stk dim= %d %d %d',stkdim(1),stkdim(2),stkdim(3)));
else,
  stkdim=size(stk);
end;
if (size(mask,1)~=stkdim(1))&(size(mask,2)~=stkdim(2)),
  warning(' image and stk dimensions do not match...');
end;

atc=zeros(stkdim(3),maskn);
stc=atc;

if length(stkdim)==4,
  for mm=1:stkdim(4), for oo=1:stkdim(3),
    tmpim=stk(:,:,oo,mm);
    if mm==1, 
      tmpsz1=size(tmpim); 
      tmpsz2=size(mask); 
      disp(sprintf('  im(%d,%d) mask(%d,%d)',tmpsz1(1),tmpsz1(2),tmpsz2(1),tmpsz2(2))); 
    end;
    for nn=1:maskn,
      atc(mm,nn,oo)=mean(tmpim(tmpmaski{nn}));
      stc(mm,nn,oo)=std(tmpim(tmpmaski{nn}));
    end;
  end; end;
elseif length(stkdim)==5,
  for pp=1:stkdim(5), for mm=1:stkdim(4), for oo=1:stkdim(3),
    tmpim=stk(:,:,oo,mm,pp);
    if mm==1, 
      tmpsz1=size(tmpim); 
      tmpsz2=size(mask); 
      disp(sprintf('  im(%d,%d) mask(%d,%d)',tmpsz1(1),tmpsz1(2),tmpsz2(1),tmpsz2(2))); 
    end;
    for nn=1:maskn,
      atc(mm,nn,oo,pp)=mean(tmpim(tmpmaski{nn}));
      stc(mm,nn,oo,pp)=std(tmpim(tmpmaski{nn}));
    end;
  end; end; end;
else,
  for mm=1:stkdim(3),
    if do_readfile,
      tmpim=readOIS3(fname,mm);
    else,
      tmpim=stk(:,:,mm);
    end;
    if mm==1, 
      tmpsz1=size(tmpim); 
      tmpsz2=size(mask); 
      disp(sprintf('  im(%d,%d) mask(%d,%d)',tmpsz1(1),tmpsz1(2),tmpsz2(1),tmpsz2(2))); 
    end;
    for nn=1:maskn,
      atc(mm,nn)=mean(tmpim(tmpmaski{nn}));
      stc(mm,nn)=std(tmpim(tmpmaski{nn}));
    end;
  end;
end;

if do_det&(do_avg==0),
  if length(dparms)==1, dparms(2:3)=[1 size(atc,1)]; end;
  if length(stkdim)==4,
    for mm=1:maskn, for oo=1:stkdim(3),
      atc(:,mm,oo)=tcdetrend(atc(:,mm,oo),dparms(1),dparms(2:end),0);
    end; end;
  elseif length(stkdim)==5,
    for mm=1:maskn, for oo=1:stkdim(3), for pp=1:stkdim(5),
      atc(:,mm,oo,pp)=tcdetrend(atc(:,mm,oo,pp),dparms(1),dparms(2:end),0);
    end; end; end;      
  else,
    for mm=1:maskn,
      atc(:,mm)=tcdetrend(atc(:,mm),dparms(1),dparms(2:end),0);
    end;
  end;
end;

if do_filt,
  if length(stkdim)==4,
    for mm=1:maskn, for oo=1:stkdim(3),
      atc(:,mm,oo)=fermi1d(atc(:,mm,oo),fparms(1),fparms(2),fparms(3),fparms(4));
    end; end;
  elseif length(stkdim)==5,
    for mm=1:maskn, for oo=1:stkdim(3), for pp=1:stkdim(5),
      atc(:,mm,oo,pp)=fermi1d(atc(:,mm,oo,pp),fparms(1),fparms(2),fparms(3),fparms(4));
    end; end; end;
  else,
    for mm=1:maskn,
      atc(:,mm)=fermi1d(atc(:,mm),fparms(1),fparms(2),fparms(3),fparms(4));
    end;
  end;
end;

if do_norm,
  if length(norm)==2, tmpni=[norm(1):norm(2)]; else, tmpni=norm; end;
  if length(stkdim)==4,
    for mm=1:maskn, for oo=1:stkdim(3),
      if do_norm==1,
        atc_n1(mm,oo)=mean(atc(tmpni,mm,oo),1);
      else,
        atc_n1(mm,oo)=mymode(atc(:,mm,oo));
      end;
      atc(:,mm,oo)=atc(:,mm,oo)/atc_n1(mm,oo);
    end; end;
  elseif length(stkdim)==5,
    for mm=1:maskn, for oo=1:stkdim(3), for pp=1:stkdim(5),
      if do_norm==1,
        atc_n1(mm,oo,pp)=mean(atc(tmpni,mm,oo,pp),1);
      else,
        atc_n1(mm,oo,pp)=mymode(atc(:,mm,oo,pp));
      end;
      atc(:,mm,oo,pp)=atc(:,mm,oo,pp)/atc_n1(mm,oo,pp);
    end; end; end;
  else,
    for mm=1:maskn,
      if do_norm==1,
        atc_n1(mm)=mean(atc(tmpni,mm),1); 
      else,
        atc_n1(mm)=mymode(atc(:,mm));
      end;
      atc(:,mm)=atc(:,mm)/atc_n1(mm);
    end;
  end;
end;

if do_avg,
  ntr=sparms(1); nimtr=sparms(2); noff=sparms(3); nkeep=sparms(4);
  if length(size(atc))==3,
    atc_orig=atc;
    stc_orig=stc;
    atc_all=reshape(atc([1:nimtr*ntr]+noff-nkeep,:,:),[nimtr ntr size(atc,2) size(atc,3)]);
    stc_all=reshape(stc([1:nimtr*ntr]+noff-nkeep,:,:),[nimtr ntr size(stc,2) size(stc,3)]);
    if do_norm,
      atc_n1_orig=atc_n1;
      atc_n1=[];
      for oo=1:size(atc_all,4), for pp=1:size(atc_all,3),
        atc_n1(:,pp,oo)=squeeze(mean(atc_all(tmpni,:,pp,oo),1));
        atc_all(:,:,pp,oo)=squeeze(atc_all(:,:,pp,oo))./(ones(size(atc_all,1),1)*squeeze(atc_n1(:,pp,oo))');
      end; end;
    end;
    atc=squeeze(mean(atc_all,2));
    stc=squeeze(std(atc_all,[],2));
  elseif length(stkdim)==5,
    disp('  avg of repetitions not yet implemented for 5-D stk, skipping...');
  else,
    atc_orig=atc;
    stc_orig=stc;
    atc_all=reshape(atc([1:nimtr*ntr]+noff-nkeep,:),[nimtr ntr size(atc,2)]);
    stc_all=[];
    if do_norm==1,
      atc_n1_orig=atc_n1;
      atc_n1=[];
      for oo=1:size(atc_all,3),
        atc_n1(:,oo)=squeeze(mean(atc_all(tmpni,:,oo),1));
        atc_all(:,:,oo)=squeeze(atc_all(:,:,oo))./(ones(size(atc_all,1),1)*squeeze(atc_n1(:,oo))');
      end;
    end;
    atc=squeeze(mean(atc_all,2));
    stc=[]; %squeeze(mean(atc_all,[],2));
  end;
  if do_det&(length(stkdim)<5),
    atc_all_orig=atc_all;
    tmpdim=size(atc_all);
    tmpatcdet=reshape(atc_all,[tmpdim(1) prod(tmpdim(2:end))]);
    for pp=1:size(tmpatcdet,2),
      tmpatcdet(:,pp)=tcdetrend(tmpatcdet(:,pp),dparms(1),dparms(2:end),0);
    end
    atc_all=reshape(tmpatcdet,tmpdim);
  end
end;

y.mask=mask;
y.nmaski=nmaski;
y.atc=squeeze(atc);
y.stc=squeeze(stc);
if do_det, y.dparms=dparms; end;
if do_filt, y.fparms=fparms; end;
if do_norm, y.nparms=norm; y.atc_n1=atc_n1; end;
if do_avg, 
    y.sparms=sparms; 
    y.atc_all=atc_all; 
    y.stc_all=stc_all; 
    y.atc_orig=atc_orig; 
    y.stc_orig=stc_orig;
    y.atc_n1_orig=atc_n1_orig;
    if exist('atc_all_orig','var'), y.atc_all_orig=atc_all_orig; end;
end;

clear tmp*


