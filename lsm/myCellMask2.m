function y=myCellMask2(ims,parms)
% Usage ... y=myCellMask2(ims,parms)
%
% parms=[ww hf smw pow thrf thrc1 thrc2 dosub]
%
% ims can be a single image or set of images
% ww: window size #frames (1-50)
% hf: spatial homogeneity factor (2-8)
% pow: power for normalization (2)
% smw: smoothing width (1)
% thrf: threshold fraction (0.1)
% thrc1: contiguity threshold (2)
% thrc2: contiguity threshold (60)
% dosub: normalize sections of the image (0)

if nargin==1, 
  parms=[size(ims,3) 2 1 1.5 0.5 2 60 0];
end;

ww=parms(1);
hf=parms(2);
smw=parms(3);
pow=parms(4);
thrf=parms(5);
thrc1=parms(6);
thrc2=parms(7);
dosub=parms(8);

sub_ww=round(0.16*mean([size(ims,1) size(ims,2)]));
sub_skp=round(0.5*sub_ww);

aims=mean(ims,3);
[aimsh,icimsh]=homocorOIS(aims,hf);
aimshmax=imlocalmax(im_smooth(aimsh,0.6*smw));
aimshmaxws=watershed_old(aimshmax);

cnt=0;
for mm=1:ceil(size(ims,3)/ww),
  cnt=cnt+1;
  tmpii=[1:ww]+(mm-1)*ww;
  if tmpii(end)>size(ims,3), tmpii=size(ims,3)-[ww-1:-1:0]; end;
  tmpim=mean(ims(:,:,tmpii),3);
  tmpims=im_smooth(tmpim,smw).*icimsh;
  if dosub,
    tmpimn=myimhistnorm_sub(tmpims,[sub_ww sub_skp]);
  else,
    tmpimn=myimhistnorm(tmpims);
  end;
  tmpimn=tmpimn.^pow;
  tmpimn=tmpimn-min(tmpimn(:)); tmpimn=tmpimn/max(tmpimn(:));
  tmpthr=thrf;
  tmpmsk=im_thr2(tmpimn,tmpthr,[thrc1 thrc2]);
  ims_norm(:,:,cnt)=tmpimn;
  ims_mask(:,:,cnt)=tmpmsk>0;
end;

y.aimh=aimsh;
y.aimh_max=aimshmax;
y.masks=ims_mask;
y.imsnorm=ims_norm;
y.avg=mean(ims_mask,3);
y.std=std(ims_mask,[],3);
y.min=min(ims_mask,[],3);
y.max=max(ims_mask,[],3);
y.mask=(y.avg>0)&(y.std==0);

if nargout==0,
  clf,
  subplot(121)
  show(ims_norm(:,:,1))
  subplot(122)
  show(ims_mask(:,:,1))
  clear y
end;
