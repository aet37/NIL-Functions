
%
% Testing the deep portion
%

k6=mykdecomp(data_sm,6,mask_sm);

ndeep=[3 2];

for mm=1:length(k6.k.ki),
  % first layer
  k6_d1(mm)=mykdecomp(data_sm,ndeep(1),k6.k.kim==mm);

  % second layer
  for nn=1:ndeep(1),
    k6_d2(mm,nn)=mykdecomp(data_sm,ndeep(1),k6_d1(mm).k.kim==nn);

    % third layer here?
    % xxx
  end;
end;


%
% Testing the cluster reproducibility in 2D and 1D
%

nk=6;
myk=mykdecomp(data_sm, ones(1,10)*nk, mask_sm);

nnn=length(myk.k);
for mm=1:nk, kim_all(:,:,mm)=myk.k{mm}.kim; end;
kim1=kim_all(:,:,1);
nk=max(tmpkim1(:));

% get the overlay for all
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

nthr=0.7;
kim_final=zeros(size(kim1));
for mm=1:nk, 
    kim_final(find(kim_all3(:,:,mm)>nthr))=mm; 
    kim_refn(mm)=sum(kim1(:)==mm); 
    kim_finaln(mm)=sum(kim_final(:)==mm); 
end;

    
