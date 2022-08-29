function [y,loc,kim]=manySubMasks(mask,mn_grid,parms,maskExcl)
% Usage ... [y,loc,kim]=manySubMasks(mask,mn_grid,parms,maskExcl)
%
% parms=[widm widn]
%

do_k=0;

if exist('parms','var'),
  if length(parms)==1,
    widm=parms(1);
    widn=parms(1);
  else,
    widm=parms(1);
    widn=parms(2);
  end;
else,
  widm=10;
  widn=10;
end;

if ~exist('maskExcl','var'), maskExcl=zeros(size(mask)); end;
if length(mn_grid)==1, mn_grid(2)=1; do_k=1; end;

tmpn=mn_grid(1:2);

[tmpx,tmpy]=find(mask==1);

if do_k,
  [ki,ci]=kmeans([tmpx(:) tmpy(:)],prod(tmpn));
  %cis=ci; 
  %[tmps,tmpsi]=sort(cis(:,1)); cis=cis(tmpsi,:); 
  %[tmps,tmpsi]=sort(cis(:,2)); cis=cis(:,tmpsi);
  %ci=cis;
  tmpkim=zeros(size(mask));
  tmpkim(find(mask==1))=ki;
  %[prod(tmpn), size(ki), size(ci)],
  tmpmask=zeros(size(mask,1),size(mask,2),size(ci,1)); 
  for mm=1:size(ci,1),
    tmpmask(:,:,mm)=ellipse(size(mask),ci(mm,1),ci(mm,2),widm,widn,0,1);
    tmpmask(:,:,mm)=tmpmask(:,:,mm)&(~maskExcl);
  end;
  tmpxx=ci(:,1);
  tmpyy=ci(:,2);
else,
  tmpx1=mean(tmpx(:))-2*std(tmpx(:)); 
  tmpx2=mean(tmpx(:))+2*std(tmpx(:));
  if tmpx1<1, tmpx1=1; end;
  if tmpx1>size(mask,1), tmpx1=size(mask,1); end;

  tmpy1=mean(tmpy(:))-2*std(tmpy(:)); 
  tmpy2=mean(tmpy(:))+2*std(tmpy(:));
  if tmpy1<1, tmpy1=1; end; 
  if tmpy1>size(mask,2), tmpy1=size(mask,2); end;

  %tmpx1=min(tmpx(:));
  %tmpy1=min(tmpy(:));
  %tmpx2=max(tmpx(:));
  %tmpy2=max(tmpy(:));
  %tmpxx=[0:1/tmpn(1):1]*(tmpx2-tmpx1)+tmpx1;
  %tmpyy=[0:1/tmpn(2):1]*(tmpy2-tmpy1)+tmpy1;

  tmpxx=[1:tmpn(1)+1]/(tmpn(1)+1); tmpxx=tmpxx*(tmpx2-tmpx1)+tmpx1;
  tmpyy=[1:tmpn(2)+1]/(tmpn(2)+1); tmpyy=tmpyy*(tmpy2-tmpy1)+tmpy1;

  tmpmask=zeros(size(mask,1),size(mask,2),prod(tmpn)); 
  tmpcnt=0;
  for mm=1:length(tmpxx), for nn=1:length(tmpyy),
    tmpcnt=tmpcnt+1;
    %tmpx0=(tmpxx(mm+1)+tmpxx(mm))/2;
    %tmpy0=(tmpyy(nn+1)+tmpyy(nn))/2;
    tmpx0=tmpxx(mm);
    tmpy0=tmpyy(nn);
    tmpmask(:,:,tmpcnt)=ellipse(size(mask),tmpx0,tmpy0,widm,widn,0,1);
    tmpmask(:,:,tmpcnt)=tmpmask(:,:,tmpcnt)&(~maskExcl);
  end; end;
  tmpkim=[];
end;

y=tmpmask;
loc=[tmpxx tmpyy];
kim=tmpkim;

clear tmp*

