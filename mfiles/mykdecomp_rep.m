function [kreps]=mykdecomp(data,nk,nrep,mask,nthr,refn)
% Usage ... [kreps]=mykdecomp(data,nk,nrep,mask,nthr,refn)
%
% This is a variant of mykdecomp that clusters data (m x n x p)
% into nk clusters using kmeans with correlalation set a the distance
% metric through nrep repetitions to determine the reliable cluster
% set ([]=def=20). Clustering can be limited to only those regions in mask,
% and the final cluster regions will be determined by the overlap or
% reliability thr nthr (def=0.7). If refn is included, this will be the 
% reference image to maintain the cluster labels.

if ~exist('mask','var'), mask=[]; end;
if ~exist('nthr','var'), nthr=[]; end;
if ~exist('nrep','var'), nrep=[]; end;
if ~exist('refn','var'), refn=[]; end;

if isempty(nthr), nthr=0.7; end;
if isempty(nrep), nrep=20; end;
if isempty(refn), refn=1; end;

if exist('tmp_mykdecomp_rep.mat','file'),
  tmpin=input('  tmp_mykdecomp_rep file found detected, load? or recompute clusters? [1/enter=yes, 0=no]: ');
  if isempty(tmpin), tmpin=1; end;
  if tmpin,
    load tmp_mykdecomp_rep myk
    %load tmp_kdecomp_rep myk nk nrep mask nthr refn
  else,
    myk=mykdecomp(data, ones(1,nrep)*nk, mask);
    save tmp_mykdecomp_rep myk nk nrep mask nthr refn
  end
elseif isstruct(data),
  disp('  using data as kcluster result');
  myk=data;
else,
  myk=mykdecomp(data, ones(1,nrep)*nk, mask);
  save tmp_mykdecomp_rep myk nk nrep mask nthr refn
end

% variable setup
% nnn- #repetitions
% nrep- #repetitions
% nk- #clusters

nnn=length(myk.k);
for mm=1:nrep, kim_all(:,:,mm)=myk.k{mm}.kim; end;

save tmp_mykdecomp_rep -append kim_all

% select kim to use as reference
if ischar(refn),
    clf,
    showmany(kim_all),
    refn=input('  select image#: ');
    if isempty(refn), refn=1; end;
end

kim1=kim_all(:,:,refn);
nk_chk=max(kim1(:));

% get the overlay for all for each image, cluster reference#, actual cluster
for mm=1:nnn,
    tmpkim=kim_all(:,:,mm);
    for nn=1:nk, for oo=1:nk,
        kk_ov(nn,oo,mm)=sum(sum((kim1==nn)&(tmpkim==oo)));
    end; end;
end;

% find the max overlay
kim_all2=zeros(size(kim_all));
for mm=1:nnn, 
    [kk_ov_maxval(:,mm),kk_ov_maxi(:,mm)]=max(kk_ov(:,:,mm),[],2); 
    tmpkim2=zeros(size(kim1));
    for nn=1:nk, tmpkim2(find(kim_all(:,:,mm)==kk_ov_maxi(nn,mm)))=nn; end;
    kim_all2(:,:,mm)=tmpkim2;
end;

for mm=1:nk, kim_all3(:,:,mm)=sum(kim_all2==mm,3); end;
kim_all3=kim_all3/nnn;

kim_final=zeros(size(kim1));
for mm=1:nk, 
    kim_final(find(kim_all3(:,:,mm)>nthr))=mm; 
    kim_refn(mm)=sum(kim1(:)==mm); 
    kim_finaln(mm)=sum(kim_final(:)==mm); 
end;


% repeat for each cluster as reference just in case
do_allref=1;
if do_allref,
  disp('  testing all cluster repetitions as reference');
  for pp=1:nnn, tmpkim1=kim_all(:,:,pp);
   for mm=1:nnn,
    tmpkim=kim_all(:,:,mm);
    for nn=1:nk, for oo=1:nk,
        tmp_kk_ov(nn,oo,mm)=sum(sum((tmpkim1==nn)&(tmpkim==oo)));
    end; end;
   end;
   tmp_kim_all2=zeros(size(kim_all));
   for mm=1:nnn, 
    [tmp_kk_ov_maxval(:,mm),tmp_kk_ov_maxi(:,mm)]=max(tmp_kk_ov(:,:,mm),[],2); 
    tmpkim2=zeros(size(kim1));
    for nn=1:nk, tmpkim2(find(kim_all(:,:,mm)==tmp_kk_ov_maxi(nn,mm)))=nn; end;
    tmp_kim_all2(:,:,mm)=tmpkim2;
   end;
   for mm=1:nk, tmp_kim_all3(:,:,mm)=sum(tmp_kim_all2==mm,3); end;
   tmp_kim_all3=tmp_kim_all3/nnn; 
   kim_all3a(:,:,:,pp)=tmp_kim_all3;
   
   tmp_kim_final=zeros(size(tmpkim1));
   for mm=1:nk, 
     tmp_kim_final(find(kim_all3a(:,:,mm,pp)>nthr))=mm; 
     tmp_kim_refn(mm)=sum(tmpkim1(:)==mm); 
     tmp_kim_finaln(mm)=sum(tmp_kim_final(:)==mm);
   end;
   kim_final_allref(:,:,pp)=tmp_kim_final;
   kim_final_allrefn(:,pp)=tmp_kim_refn;
   kim_final_alln(:,pp)=tmp_kim_finaln;
   
   clear tmpkim1 tmp_kk_ov* tmp_kim_all2 tmp_kim_all3 tmp_kim_final tmp_kim_refn tmp_kim_finaln 
  end
  
  % decide which cluster selection is best ???
  [tmpmin,tmpmin_i]=min(sqrt(mean([kim_final_alln-kim_final_allrefn].^2,1)));
  kim_final_all=kim_final_allref(:,:,tmpmin_i);
  kim_final_all_ref=kim_all(:,:,tmpmin_i);
  kim_mse_all_ref=sqrt(mean([kim_final_alln-kim_final_allrefn].^2,1));
  kim_mse_all_imin=[tmpmin_i];
end


kreps.kim_final=kim_final;
kreps.kim_final_all=kim_all3;
kreps.kim_all_reor=kim_all2;
kreps.kim_all=kim_all;
kreps.kov_f=kk_ov;
kreps.kov_maxi=kk_ov_maxi;
kreps.kov_maxval=kk_ov_maxval;
kreps.nrep=nrep;
kreps.nk=ones(1,nrep)*nk;
kreps.mask=mask;
kreps.kim_ref=kim1;
kreps.n_final=kim_finaln;
kreps.n_ref=kim_refn;
if do_allref, 
    kreps.kim_final_allref=kim_final_allref;
    kreps.kim_final_allref_1=kim_final_all;
    %kreps.kim_final_allref_ref=kim_final_all_ref;
    kreps.kim_allref_mse_ref=kim_mse_all_ref;
    kreps.kim_allref_mse_imin=kim_mse_all_imin;
    kreps.kim_allref_kov=kim_final_allref;
    kreps.kim_allrefn_kov=kim_final_allrefn;
    kreps.kim_alln_kov=kim_final_alln;
    kreps.kim_allref_3=kim_all3a;
end

%if exist('tmp_kdecomp_rep.mat','file'),
%    delete('tmp_kdecomp_rep.mat')
%end

if nargout==0,
    if do_allref,
        subplot(121), imagesc(kreps.kim_final), axis image, colormap jet, colorbar,
        xlabel('kim final -- selected reference')
        subplot(122),imagesc(kreps.kim_final_allref_1), axis image, colormap jet, colorbar,
        xlabel('kim final -- mse min reference'),
    else,
        imagesc(kreps.kim_final), axis image, colormap jet, colorbar,
    end
end

