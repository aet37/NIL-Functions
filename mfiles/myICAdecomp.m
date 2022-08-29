function [y,ica_cor]=myICAdecomp(x,n_ica,mask,transp_flag,avg_flag,type) 
% Usage ... [y,ica_cor]=myICAdecomp(x,n_ica,mask,transp_flag,avg_flag,type) 

x=squeeze(x);

do_type=1;
do_reshape=0;
xdim=size(x);
maxsize=192*192;

if nargin<6, type=1; end;
if nargin<5, mask=[]; end;
if nargin<4, avg_flag=[]; end;
if nargin<3, transp_flag=[]; end;
if nargin<2, n_ica=20; end;

if isempty(avg_flag), do_rmavg=1; else, do_rmavg=avg_flag; end;
if isempty(transp_flag), transp_flag=1; end;

if isempty(mask),
  if length(xdim)==3, mask=ones(xdim(1:2)); else, mask=1; end;
end;
if isempty(transp_flag), transp_flag=1; end;

if length(xdim)==3, 
  if length(mask)>1,
    do_reshape=2;
    maskii=find(mask);
    xavg=mean(x,3);
    xnew=reshape(x,[size(x,1)*size(x,2) size(x,3)]);
    xnew=xnew(maskii,:);
    xavg=mean(xnew,2);
    x=xnew;
    clear xnew
  elseif prod(xdim(1:2))>maxsize,
    do_reshape=1;
    nbin=ceil(prod(xdim(1:2))/maxsize);
    disp(sprintf('  warning: 3-d data size is large, binning down by %d...',nbin));
    for mm=1:xdim(3), xnew(:,:,mm)=imbin(x(:,:,mm),nbin); end;
    clear x
    x=xnew;
    clear xnew
    xdim=size(x);
    xavg=mean(x,3); 
  end;
else, 
  xavg=mean(x,2); 
end;


if do_type==1,
  % type 1 is fastica
  addpath('/Users/towi/matlab/fastICA_25')
  if do_reshape==1,
    if transp_flag,
      if do_rmavg,
        [ica,ica_A,ica_W]=fastica(reshape(x-repmat(xavg,[1 1 xdim(3)]),xdim(1)*xdim(2),xdim(3))','numOfIC',n_ica);
      else,
        [ica,ica_A,ica_W]=fastica(reshape(x,xdim(1)*xdim(2),xdim(3))','numOfIC',n_ica);
      end;
    else,
      if do_rmavg,
        [ica,ica_A,ica_W]=fastica(reshape(x-repmat(xavg,[1 1 xdim(3)]),xdim(1)*xdim(2),xdim(3)),'numOfIC',n_ica);
      else,
        [ica,ica_A,ica_W]=fastica(reshape(x,xdim(1)*xdim(2),xdim(3)),'numOfIC',n_ica);
      end;
    end;
  else,
    if transp_flag,
      if do_rmavg,
        [ica,ica_A,ica_W]=fastica((x-xavg*ones(1,size(x,2)))','numOfIC',n_ica);       
      else,
        [ica,ica_A,ica_W]=fastica(x','numOfIC',n_ica);
      end;
    else,
      if do_rmavg,
        [ica,ica_A,ica_W]=fastica(x-xavg*ones(1,size(x,2)),'numOfIC',n_ica);
      else,
        [ica,ica_A,ica_W]=fastica(x,'numOfIC',n_ica);
      end;
    end;
  end;
end;

% if do_reshape,
%   for mm=1:size(ica,1), ica_cor(:,:,mm)=OIS_corr2(x,ica(mm,:)'); end;
%   if do_reshape==2,
%       for mm=1:size(ica_A,2), 
%           tmpim=zeros(xdim(1),xdim(2)); 
%           tmpim(maskii)=ica_A(:,mm); 
%           ica_map(:,:,mm)=tmpim; 
%       end;
%   else
%       for mm=1:size(ica_A,2), ica_map(:,:,mm)=reshape(ica_A(:,mm),xdim(1),xdim(2)); end;
%   end
% else,
%   ica_map=[];
%   ica_cor=corrcoef(ica);
% end;

if nargout==1,
  y.ica=ica;
  y.ica_A=ica_A;
  y.ica_W=ica_W;
%   if do_reshape,
%     y.ica=ica_map;
%     y.cor=ica_cor;
%   end;
end;
 
