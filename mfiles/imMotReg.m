function [y,ss]=imMotReg(x,xmp,parms,xr2,flags,ii_in)
% Usage ... [y,str]=imMotReg(x,xmp,parms,xr2,flags,ii_in)
%
% x is the data, xmp is the motion parameters,
% parm=[mot_frac_thr_for_filtering  verify_flag], xr2 is additional regressors,
% flags=[verify_flag(1=verify,-1=all,-2=reg-only,-3=motc-only)]
% ii_in= data indices to consider for coefficient calculation
%
% Ex. [data_ic,xx_intc]=imMotReg(data,xx_motc,mask_reg_tc.atc,1);
%     data_ic=imMotReg(data,xx_motc,0,[],1);

x=squeeze(x);

do_zscore=1;
do_single=1;
do_verify=0;

if nargin<5, flags=[]; end;
if isempty(flags), do_verify=0; else, do_verify=flags(1); end;

if ~exist('ii_in','var'), ii_in=[]; end;

if nargin<3, parms=[]; end;
if isempty(parms), parms=0.0; end;
if length(parms)==2, do_verify=parms(2); end;

mot_thr=parms(1);	% 0.1

if ~isempty(xmp),
  mot_est=sum(abs(xmp(:))<0.3)/length(xmp(:));
  disp(sprintf('  est mot fraction= %.3f',(sum(abs(xmp(:))<1)/length(xmp(:))))),
  if mot_est<=mot_thr,
    disp(sprintf('  n=%d, co=%d, w=%d',size(xmp,1),ceil(0.32*size(xmp,1)),ceil(0.008*size(xmp,1))));
    xmps(:,1)=fermi1d(xmp(:,1),ceil(0.32*size(xmp,1)),ceil(0.008*size(xmp,1)),1);
    xmps(:,2)=fermi1d(xmp(:,2),ceil(0.32*size(xmp,1)),ceil(0.008*size(xmp,1)),1);
  else,
    disp('  no filtering of motion regressors'),
    xmps=xmp;
  end;

  tmpreg=[xmps  xmps.^2 xmps.^3 abs(xmps).^0.5 (xmps(:,1).*xmps(:,2)) ...
       (xmps(:,1).*xmps(:,2)).^2 abs(xmps(:,1).*xmps(:,2)).^0.5];
else,
  tmpreg=[];
end;
i1reg=length(tmpreg);

do_filtxr2=0;

if exist('xr2','var'),
  tmpreg1=tmpreg;
  if iscell(xr2),
    tmpreg2=xr2{1};
  else,
    tmpreg2=xr2;
  end;
  if do_filtxr2,
      tmpreg2_orig=tmpreg2;
      tmphco=36; 
      if size(tmpreg2,1)<(10*tmphco), tmphco=floor(0.1*size(tmpreg2,1)); end;
      tmphcw=tmphco/4;
      for mm=1:size(tmpreg2,2),
          tmpreg2(:,mm)=fermi1d(tmpreg2(:,mm),tmphfco,tmphcw,-1)+mean(tmpreg2(:,mm));
      end
  end
  tmpreg=[tmpreg1 tmpreg2];
else,
  tmpreg1=tmpreg;
  xr2=[];
end;

if do_verify,
  if do_verify<0,
    tmpin=abs(do_verify);
  else,
    clf,
    subplot(211), plot(tmpreg), axis('tight'), grid('on'),
    subplot(212), plot(zscore(tmpreg)), axis('tight'), grid('on'),
    tmpin=input('  imMotReg continue? [0=no, 1=yes, 2=xr2-only, 3=xx-only]: ');
    if isempty(tmpin), tmpin=1; end;
  end;
  if tmpin==0,
    y=x; ss=[];
    return;
  elseif tmpin==2,
    if isempty(xr2),
      disp('  secondary regressors empty...');
    else,
      disp('  only using secondary regressors...');
      tmpreg=xr2;
    end;
  elseif tmpin==3,
    disp('  motion parameters only...');
    if size(tmpreg,2)==size(xr2,2),
      disp('  no motion parameters detected, continuing with regression');
    else,
      tmpreg=tmpreg(:,1:end-size(xr2,2));
    end;
  end;
end;

if do_zscore, 
  disp('  zscore normalized regressors');
  tmpreg=zscore(tmpreg); 
  tmpreg1=zscore(tmpreg1);
end;

if length(size(x))==4,
  if do_single, y=single(zeros(size(x))); else, y=zeros(size(x)); end;
  for pp=1:size(x,3),
    if iscell(xr2),
      tmpreg2a=[tmpreg1 zscore(xr2{pp})];
    else,
      tmpreg2a=[tmpreg1 zscore(xr2)];
    end;
    x_mrb=zeros(size(x,1),size(x,2),size(tmpreg,2)+1);
    disp(sprintf('  regressing %d from #%d',size(tmpreg2a,2),pp));
    for mm=1:size(x,1),
      %tmpmr=mreg(tmpreg2a,double(squeeze(x(mm,:,pp,:)))',1);
      tmpmr=mreg(tmpreg2a,double(squeeze(x(mm,:,pp,:)))',1,1,ii_in);
      x_mrb(mm,:,:)=tmpmr.b';
      if do_single,
        y(mm,:,pp,:)=single(tmpmr.yf');
      else,
        y(mm,:,pp,:)=tmpmr.yf';
      end;
    end;

    ss(pp).reg=tmpreg2a;
    ss(pp).b=x_mrb;
  end;
else,
  x_mrb=zeros(size(x,1),size(x,2),size(tmpreg,2)+1);
  if do_single, y=single(zeros(size(x))); else, y=zeros(size(x)); end;
  for mm=1:size(x,1),
    %tmpmr=mreg(tmpreg,double(squeeze(x(mm,:,:)))',1);
    tmpmr=mreg(tmpreg,double(squeeze(x(mm,:,:)))',1,1,ii_in);
    x_mrb(mm,:,:)=tmpmr.b';
    if do_single,
      y(mm,:,:)=single(tmpmr.yf');
    else,
      y(mm,:,:)=tmpmr.yf';
    end;
  end;

  ss.reg=tmpreg;
  ss.b=x_mrb;
end;


