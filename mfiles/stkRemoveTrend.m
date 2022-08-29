function [maps,ims_c,mask]=stkRemoveTrend(fname,parms,mask,nims)
% Usage ... y=stkRemoveTrend(fname,parms,mask,nims)
% 
% parms = [nord(1) nblk(100) save_flag(1) saveorig_flag(0)]
%

tic,

if nargin<4, nims=[]; end;
if nargin<3, mask=[]; end;
if nargin<2, parms=[]; end;

if isempty(parms),
  parms=[1 100 1 0];
end;
nord=parms(1);
nblk=parms(2);
save_flag=parms(3);
check_flag=parms(4);

if isempty(mask),
  mask_select=1;
elseif strcmp(mask,'select'),
  mask_select=1;
else,
  mask_select=0;
end;

tmpstk=tiffread2(fname,1);
im1=double(tmpstk.data);

% select mask if necessary
if mask_select,
  clear mask
  found=0;
  while(~found),
    clf, show(im1), drawnow,
    disp('  select area...');
    mask=roipoly;
    show(im_super(im1,mask,0.3)), drawnow,
    found=input('  area OK? [0=no, 1=yes]: ');
  end;
end;
maski=find(mask);
maskn=length(mask);

% determine nims if not provided
if isempty(nims),
  found=0;
  nims=2;
  disp('  determining #images...');
  while(~found),
    tmpstk=tiffread2(fname,nims);
    if isempty(tmpstk),
      nims=nims-1;
      break;
    else,
      nims=nims+1;
    end;
  end;
  clear tmpstk
end;

% load data, get data from mask
cnt=0; cnt1=0;
found=0;
ims=zeros(size(im1,1),size(im1,2),nims);
disp('  reading data...');
while(~found),
  disp(sprintf('    im# %04d',cnt1));
  tmpstk=tiffread2(fname,cnt1+1,cnt1+nblk);
  for mm=1:length(tmpstk),
    cnt=cnt+1;
    ims(:,:,cnt)=tmpstk(mm).data;
    tmpim=double(tmpstk(mm).data);
    masktc(cnt)=sum(tmpim(maski))/maskn;
    comtc(cnt,:)=imCenterMass(tmpim);
  end;
  if mm~=nblk, found=1; else, cnt1=cnt1+nblk; nims=cnt; end;
end;
im9=double(ims(:,:,end));
comtc=[comtc(:,1)-comtc(1,1) comtc(:,2)-comtc(1,2)];
comtcd=sqrt((comtc(:,1).^2+comtc(:,2).^2));

% display mask tc
clf,
subplot(211)
plot(masktc)
title('Mask TC'),
subplot(212)
plot(comtcd)
title('Center of Mass TC'),
drawnow,

% detrending
ims_c=ims;
disp(sprintf('  detrending (%d order)...',nord));
for mm=1:size(ims,1), for nn=1:size(ims,2),
  tmptc=double(squeeze(ims(mm,nn,:)));
  tmpp=polyfit(masktc(:),tmptc(:),nord);
  tmpfit=polyval(tmpp,masktc(:));
  tmptc2=tmptc-tmpfit+mean(tmpfit);
  maps(mm,nn,:)=tmpp;
  ims_c(mm,nn,:)=uint16(round(tmptc2));
  tmpp=polyfit(comtcd(:),tmptc(:),1);
  maps_1com(mm,nn,:)=tmpp;
end; end;


% saving
if length(parms)>1,
  save_flag=parms(2);
else,
  save_flag=1;
  check_flag=0;
end;
oname=sprintf('%s_%ddetcorr.mat',fname(1:end-4),nord);
disp(sprintf('  saving %s',oname));
if prod(size(ims_c))>2e8,
  eval(sprintf('save %s -v7.3 fname maps ims_c mask masktc comtc comtcd maps_1com im1 im9 ',oname))
  if check_flag, eval(sprintf('save %s -append ims',oname)); end;
else,
  eval(sprintf('save %s fname maps ims_c mask masktc comtc comtcd maps_1com im1 im9 ',oname))
  if check_flag, eval(sprintf('save %s -append ims',oname)); end;
end;

ett=toc;
disp(sprintf('  elapsed time= %.1f',ett));

if nargout==0, 
  clear maps ims_c mask
end

