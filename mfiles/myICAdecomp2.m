function [y,ica_cor]=myicadecomp(x,n_ica,mask,transp_flag,do_type) 
% Usage ... [y,ica_cor]=myicadecomp(x,n_ica,mask,transp_flag,type) 

if ~exist('mask','var'), mask=[]; end;
if ~exist('transp_flag','var'), transp_flag=0; end;
if ~exist('do_type','var'), do_type=1; end;

do_type=1;
do_reshape=0;
xdim=size(x);
maxsize=192*192;

if length(xdim)==3, 
  do_reshape=1;
  if prod(xdim(1:2))>maxsize,
    nbin=ceil(prod(xdim(1:2))/maxsize);
    disp(sprintf('  warning: 3-d data size is large, recommend binning down by %d...',nbin));
  end;
  xavg=mean(x,3); 
else, 
  xavg=mean(x,2); 
end;

if isempty(mask), 
    if length(size(x))==3, 
        mask=ones(xdim(1:2)); 
    else, 
        mask=ones([xdim(1),1]); 
    end; 
end;

if isempty(n_ica), n_ica=20; end;

maski=find(mask);

if do_type==1,
  % type 1 is fastica
  addpath('/Users/towi/matlab/fastICA_25')
  if do_reshape,
    xx=reshape(x-repmat(xavg,[1 1 xdim(3)]),xdim(1)*xdim(2),xdim(3));
    xx=xx(maski,:);
    xxavg=xavg(maski);
  else,
    xx=x(maski,:);
    xxavg=xavg(maski);
  end;
  disp(sprintf('  starting ica (%d,%d; %d,%d)...',size(x,1),size(x,2),size(xx,1),size(xx,2)));
  if transp_flag,
    [ica,ica_A,ica_W]=fastica((xx-xxavg*ones(1,size(xx,2)))','numOfIC',n_ica);    
  else,
    [ica,ica_A,ica_W]=fastica(xx-xxavg*ones(1,size(xx,2)),'numOfIC',n_ica);
  end;
  clear xx xxavg
end;

if do_reshape,
  for mm=1:size(ica,1), ica_cor(:,:,mm)=OIS_corr2(x,ica(mm,:)'); end;
  for mm=1:size(ica_A,2), tmpim=zeros(size(x,1),size(x,2)); tmpim(maski)=ica_A(:,mm); ica_map(:,:,mm)=tmpim; end;
else,
  ica_map=[];
  ica_cor=corrcoef(ica);
end;

if nargout==1,
  y.ica=ica;
  y.ica_A=ica_A;
  y.mask=mask;
  y.map=ica_map;
  y.cor=ica_cor;
end;

