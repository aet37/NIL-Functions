function y=mypcadecomp(x,npca,mask,transp_flag,average_flag)
% Usage ... y=mypcadecomp(x,npca,mask,transp_flag,average_flag)
%
% SVD-based PCA decomposition. Mask can be used to include only items from
% the first dimensions of X instead of the whole thing.
%
% Examples:
%   mypca1=mypcadecomp(snp.ys');
%   data1=mypca1.pca*diag(mypca1.pca_e)*mypca1.pca_w';

do_econ=0;
x=squeeze(x);

if nargin<5, average_flag=[]; end;
if nargin<4, transp_flag=[]; end;
if nargin<3, mask=[]; end;
if nargin<2, npca=[]; end;

xdim=size(x);

do_reshape=0;
if length(xdim)>2, do_reshape=1; end;

do_average=0;
if isempty(average_flag), do_average=0; else, do_average=average_flag; end;
if isempty(transp_flag), transp_flag=0; end;

if do_reshape,
  disp('  reshaping...');
  if isempty(mask), mask=ones(xdim(1),xdim(2)); end;
  maski=find(mask);
  tmplabel=[1:length(maski)];
  %tmplabel=reshape([1:xdim(1)*xdim(2)],xdim(1),xdim(2));
  %tmpk=mykmeans(reshape(x,xdim(1)*xdim(2),xdim(3))',2:nk,tmplabel);
  tmpdata=reshape(x,[xdim(1)*xdim(2),xdim(3)]);
  tmpdata=tmpdata(maski,:);
else,
  tmpdata=x;
  %if nargin==3, transp_flag=mask; end;
  if isempty(mask), 
    maski=[1:size(tmpdata,1)];
  else,
    maski=find(mask);
  end;
  tmpdata=tmpdata(maski,:);
end;

if transp_flag,
  tmpdata=tmpdata.';
end;

if do_average,
  tmpavg=mean(tmpdata,2);
  tmpdata=tmpdata-tmpavg*ones(1,size(tmpdata,2));
elseif do_average==2,
  tmpavg=mean(tmpdata,2);
  tmpdata=tmpdata-tmpavg*ones(1,size(tmpdata,2));
  tmpavg2=mean(tmpdata,1);
  tmpdata=tmpdata-ones(size(tmpdata,1),1)*tmpavg2;
elseif do_average==3,
  tmpdata=zscore(tmpdata,[],2);
end;

if prod(size(tmpdata))>40e6, do_econ=1; end;

disp(sprintf('  transp_flag=%d, average_flag=%d, econ_flag=%d',transp_flag,do_average,do_econ));

% finally calculate SVD
if do_econ,
    [tmppca,tmppca_e,tmppca_w]=svd(tmpdata',0);
else,
    [tmppca,tmppca_e,tmppca_w]=svd(tmpdata');
end


tmppca_e=diag(tmppca_e);
tmppca_e2=(tmppca_e.^2);
tmppca_e2s=cumsum(tmppca_e2./sum(tmppca_e2));
if isempty(npca), npca=length(tmppca_e); end;
if npca<1, npca=find(tmppca_e2s>npca,1); end;
clear tmpdata

disp(sprintf('  assigning components (%d)...',npca));
tmppca_e_keep=tmppca_e(1:npca);

tmppca_keep=tmppca(:,1:npca);
tmppca_w_keep=tmppca_w(1:npca,:);

if (do_reshape)&(npca<=40),
  if transp_flag,
    disp('  making images of components...');
    tmpnotes='ims of components (U), rims of coefficients (V)';
    tmpavgim(maski)=tmpavg2(maski);
    for mm=1:npca,
        tmpim=zeros(xdim(1),xdim(2));
        tmpim(maski)=tmppca(:,mm);
        tmppca_w_ims(:,:,mm)=tmpim;
    end;
    for mm=1:npca,
        tmppca_r_ims(:,:,mm)=OIS_corr2(x,tmppca_w_keep(mm,:)');
    end;
  else,
    disp('  making images of component coefficients then correlating with components...');
    tmpnotes='ims of component coefficients (W), rims of components (U)';
    tmpavgim=zeros(xdim(1),xdim(2));
    if ~exist('tmpavg','var'), tmpavg=mean(x,3); end;
    tmpavgim(maski)=tmpavg(maski);
    tmppca_w_ims=zeros(xdim(1),xdim(2),npca);
    for mm=1:npca,
      tmpim=zeros(xdim(1),xdim(2));
      tmpim(maski)=tmppca_w_keep(mm,:);
      tmppca_w_ims(:,:,mm)=tmpim;
    end;
    tmppca_r_ims=zeros(xdim(1),xdim(2),npca);
    for mm=1:npca,
      tmppca_r_ims(:,:,mm)=OIS_corr2(x,tmppca_keep(:,mm));
    end;
  end;
else,
  tmppca_r_ims=[];
end;



y.pca=tmppca_keep;
y.pca_e=tmppca_e_keep;
y.pca_w=tmppca_w_keep;
y.pca_e_orig=tmppca_e;
y.avg_flag=average_flag;
y.transp_flag=transp_flag;

if do_average, y.avg=tmpavg; end;

if do_reshape,
  y.mask=mask;
  if npca<=40,
    y.notes=tmpnotes;
    y.avg_im=tmpavgim;
    y.pca_im=tmppca_w_ims;
    y.pca_rim=tmppca_r_ims;
    if nargout==0,
      tile3d(tmppca_w_ims);
    end;
  end;
end;

