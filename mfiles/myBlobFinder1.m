
clear all
close all

load tmp_zser_data

im=data(:,:,2,36);

oo=1;
smw_0=2;
smw_step=2;

imdim=size(im);
smw_1=4*round(sqrt(max(size(im))));
smw_corner=52;

smw_all=[2*smw_0:smw_step:smw_1];
smw_alt=(smw_all-smw_corner).*(smw_all>smw_corner);
smw_alt(find(smw_alt==0))=smw_0;

smw_all=[10:2:80];
smw_alt=smw_all-8;

nsmw=length(smw_all);

im0s=im_smooth(im,smw_0);
im1s=zeros(imdim(1),imdim(2),nsmw);
for mm=1:length(smw_all),
    im1s(:,:,mm)=im_smooth(im,smw_all(mm));
    im1d(:,:,mm)=im_smooth(im,smw_alt(mm))-im1s(:,:,mm);
end

im_max=max(im1d,[],3);

im_max_end=zeros(imdim);
im_max_k=zeros(imdim);
im_max_n=zeros(imdim);
for mm=1:size(im,1), for nn=1:size(im,2),
  tmpmax=im_max(mm,nn);
  tmpkk=find(squeeze(im1d(mm,nn,:))==tmpmax);
  
  if mm>oo, tmpni=[-oo:oo]+mm; else, tmpni=[1:mm]; end;
  if mm>=(imdim(1)-oo+1), tmpni=[mm:imdim(1)]; end;
  if nn>oo, tmpnj=[-oo:oo]+nn; else, tmpnj=[1:nn]; end;
  if nn>=(imdim(2)-oo+1), tmpnj=[nn:imdim(2)]; end;
  if tmpkk>1, tmpnk=[-1:1]+tmpkk(1); else, tmpnk=[0:1]+tmpkk(1); end;
  if tmpkk==nsmw, tmpnk=[-1:0]+tmpkk(1); end;
  
  tmpneigh=im1d(tmpni,tmpnj,tmpnk);
  %if (mm==168)&(nn==262),
  %    tmpni, tmpnj, tmpnk, tmpneigh,
  %    keyboard,
  %end;
  im_max_n(mm,nn)=sum((tmpmax)>tmpneigh(:));
  if (tmpmax>0)&(sum((tmpmax+100*eps)>tmpneigh(:))==1), im_max_end(mm,nn)=tmpmax; im_max_k(mm,nn)=tmpkk; end;
end; end;

rco=0.67*max(smw_all);
rww=rco/4;

im_mask=zeros(imdim);
[tmpmaxi,tmpmaxj]=find(im_max_end>0.35*max(im_max_end(:)));
[tmpii,tmpjj]=meshgrid([1:imdim(1)],[1:imdim(2)]');
for mm=1:length(tmpmaxi),
  tmpkk=im_max_k(tmpmaxi(mm),tmpmaxj(mm));
  %tmpmax=im_max_end(tmpmaxi(mm),tmpmaxj(mm));
  tmpmax=im1d(tmpmaxi(mm),tmpmaxj(mm),tmpkk)*0.71;
  tmprr=sqrt((tmpii-tmpmaxi(mm)).^2+(tmpjj-tmpmaxj(mm)).^2);
  tmpr1=1./(1+exp((tmprr-rco)/rww));
  im_mask=im_mask|(im1d(:,:,tmpkk)>=tmpmax);
  %im_mask=im_mask|((im1d(:,:,tmpkk).*tmpr1)>=tmpmax);
  subplot(121), show(im1d(:,:,tmpkk)),
  xlabel(sprintf('%d/%d: %d, %f/%f',mm,length(tmpmaxi),tmpkk,tmpmax,max(max(im1d(:,:,tmpkk))))); 
  subplot(122), show((im1d(:,:,tmpkk))>tmpmax),
  xlabel('Mask'),
  drawnow,
  pause,
end

clf, 
subplot(121), show(im_mask),
subplot(122), im_overlay4(im,im_mask>0),

