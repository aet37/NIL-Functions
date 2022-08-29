function [pca,pca_e,pca_map,pca_corr]=mypcadecomp(x,nkeep,transp_flag,rmavg_flag) 
% Usage ... [pca,pca_e,pca_map,pca_corr]=mypcadecomp(x,n_pca,transpose_flag,rmavg_flag) 
%
% for 3D input, default is to run PCA in image domain

if nargin<4, do_rmavg=1; else, do_rmavg=rmavg_flag; end;

do_reshape=0;
xdim=size(x);
maxsize=192*192;

if length(xdim)==3, 
  do_reshape=1;
  if prod(xdim(1:2))>maxsize,
    nbin=ceil(prod(xdim(1:2))/maxsize);
    disp(sprintf('  warning: 3-d data size is large, binning down by %d...',nbin));
    for mm=1:xdim(3), xnew(:,:,mm)=imbin(x(:,:,mm),nbin); end;
    clear x
    x=xnew;
    clear xnew
    xdim=size(x);
  end;
  xavg=mean(x,3); 
else, 
  xavg=mean(x,2); 
end;
if nargin<3, transp_flag=0; end;
if nargin<2, nkeep=20; end;

if transp_flag,
  if do_reshape,
    if do_rmavg,
      [pca,pca_e,pca_w]=svd( reshape(x-repmat(xavg,[1 1 xdim(3)]),xdim(1)*xdim(2),xdim(3))' );    
    else,
      [pca,pca_e,pca_w]=svd( reshape(x,xdim(1)*xdim(2),xdim(3))' );    
    end;
  else,
    if do_rmavg,
      [pca,pca_e,pca_w]=svd( (x-xavg*ones(1,size(x,2)))' );
    else,
      [pca,pca_e,pca_w]=svd( x' );
    end;
  end;
else,
  if do_reshape,
    if do_rmavg,
      [pca,pca_e,pca_w]=svd( reshape(x-repmat(xavg,[1 1 xdim(3)]),xdim(1)*xdim(2),xdim(3)) );
    else,
      [pca,pca_e,pca_w]=svd( reshape(x,xdim(1)*xdim(2),xdim(3)) );
    end;
  else,
    if do_rmavg,
      [pca,pca_e,pca_w]=svd( x-xavg*ones(1,size(x,2)) );
    else,
      [pca,pca_e,pca_w]=svd( x );
    end;
  end;
end;
pca_e_d=diag(pca_e);
pca_en=pca_e_d/pca_e_d(1);
pca_ex=cumsum(pca_e_d.^2)/sum(pca_e_d.^2);

do_xreduce=0;
if (nkeep>0)&(nkeep<1),
  do_xreduce=1;
  ethr=nkeep;
  tmpi=find(pca_ex>nkeep,1);
  if ~isempty(tmpi), nkeep=tmpi(end); else, nkeep=1; end;
  disp(sprintf('  keeping %d...',nkeep));
  new_pca_e=zeros(size(pca_e));
  new_pca_e(1:nkeep,1:nkeep)=diag(pca_e(1:nkeep));
  xrec=pca(:,1:nkeep)*diag(pca_e_d(1:nkeep))*pca_w(:,1:nkeep)'; 
  % add mean back??
  if do_reshape,
    for mm=1:size(xrec,2),
      xrec_new(:,:,mm)=reshape(xrec(:,mm),xdim(1),xdim(2));
    end;
    xrec=xrec_new; clear xrec_new
  end;
end;

for mm=1:nkeep,
  if do_reshape,
    if size(pca,1)==prod(xdim(1:2)),
      pca_map(:,:,mm)=reshape(pca(:,mm),xdim(1),xdim(2));
      if ~do_xreduce, pca_cor(:,:,mm)=OIS_corr2(x,pca_w(:,mm)); end;
    else,
      pca_map(:,:,mm)=reshape(pca_w(:,mm),xdim(1),xdim(2));
      if ~do_xreduce, pca_cor(:,:,mm)=OIS_corr2(x,pca(:,mm)); end;
    end;
  else,
    pca_map=[];
    pca_cor=corrcoef(pca(:,1:nkeep));
  end;
  %pca_cor2=OIS_corr2(pca1.map2,squeeze(pca1.map2(10,30,:)))>0.5
end;

%plot(diag(pca_e))
%show( reshape(pca(:,1),xdim(1),xdim(2)))

if nargout==1,
  tmpstr.pca=pca;
  tmpstr.pca_e=pca_e_d;
  tmpstr.pca_es=pca_ex;
  tmpstr.pca_w=pca_w;
  if do_reshape, tmpstr.pca=pca_map; end;
  if do_xreduce,
    tmpstr.nkeep=nkeep;
    tmpstr.e_thr=ethr;
    tmpstr.x_red=xrec;
  else,
    tmpstr.cor=pca_cor;
  end;
  clear pca
  pca=tmpstr;
  clear tmpstr
end;

