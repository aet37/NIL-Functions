function [y,ys]=xferMask1(origMask,origIm,newIm,parms)
% Usage ... [y,ys]=xferMask1(origMask,origIm,newIm,parms_or_xferYS)
%
% parms=[msk_type xfer_opt] OR parms=prevYS
% msk_type=[0=binary, 1=labeled, 2=image]
% xfer_opt=[1=point-select, 3=auto]
%
% Ex. [maskAA,xf1]=xferMask1(maskAA_ref,avgim_ref,avgim_bin);
%      maskVV=xferMask1(maskVV_ref,xf1);

if nargin<4, parms=[0 1]; end;

do_apply=0;
if isstruct(parms),
  do_apply=1;
  mask_type=parms.mask_type;
  xfer_type=parms.xfer_type;
  xo0to1=parms.xo0to1;
  xx0to1=parms.xx0to1;
  if isempty(newIm), newIm=parms.newIm; end;
elseif isstruct(origIm),
  do_apply=1;
  parms=origIm;
  mask_type=parms.mask_type;
  xfer_type=parms.xfer_type;
  xo0to1=parms.xo0to1;
  xx0to1=parms.xx0to1;
  newIm=parms.newIm;
  origIm=parms.origIm;
else,
  if length(parms)==1, parms(2)=1; end;
  mask_type=parms(1);
  xfer_type=parms(2);
end;

tmpim_ref=origIm;
tmpim=newIm;
tmpmask_ref=origMask;

if do_apply==0,
  [tmpim_ref1,xo0to1]=imFlipSelect(tmpim_ref,tmpim); 
  tmpmask_ref1=imFlipSelect(tmpmask_ref,xo0to1);
  if mask_type==3,
    xx0to1=myaffine2d_scr(double(imwlevel(tmpim_ref1,[],1)),double(imwlevel(tmpim,[],1)));
  else,
    xx0to1=myaffine2d_scr(tmpim_ref1,tmpim,[],'point-select');
  end;
else,
  tmpmask_ref1=imFlipSelect(tmpmask_ref,xo0to1);
end;

tmpmask=zeros(size(newIm));
tmpaffim=zeros(size(newIm));
if xfer_type==0,
  tmpaffim=myaffine2d_f(double(tmpmask_ref1>0),xx0to1,size(tmpmask));
  tmpmask(find(tmpaffim.^2>0.5))=1;
elseif xfer_type==2,
  tmpaffim=myaffine2d_f(tmpmask_ref1,xx0to1,size(tmpmask));
  tmpmask=tmpaffim;
else,
  for mm=1:max(tmpmask_ref1(:)),
    tmpaffim=myaffine2d_f(double(tmpmask_ref1==mm),xx0to1,size(tmpmask));
    tmpmask(find(tmpaffim.^2>0.5))=mm;
  end;
end;

y=tmpmask;
ys.newIm=newIm;
ys.newMask=tmpmask;
ys.origIm=origIm;
ys.origMask=origMask;
ys.mask_type=mask_type;
ys.xfer_type=xfer_type;
ys.xx0to1=xx0to1;
ys.xo0to1=xo0to1;

do_fig=0;
if nargout==0, do_fig=1; end;

if do_fig,
  figure(1), clf,
  subplot(121), show(im_super(origIm,origMask,0.3)), xlabel('Original Reference'),
  subplot(122), show(im_super(newIm,y,0.3)), xlabel('Xfer Result'),
  drawnow,
end;

