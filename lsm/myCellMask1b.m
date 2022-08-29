function y=myCellMask1b(mask,im,parms)
% Usage ... y=myCellMask1b(mask,im,parms)
%
% parms = [edge_neigh_pix(1) top_f_pix(0.5) top_n_pix(3)]
% This function returns a structure with masks ending in
% g - edge, e- eroded, p- top_percent, n- top_npix

if ~exist('parms'), parms=[]; end;
if isempty(parms), parms=[1 0.5 3]; end;

nn1=parms(1)*2+1;
fthr=parms(2);
nthr=parms(3);

maskg=zeros(size(mask));
maske=zeros(size(mask));
maskp=zeros(size(mask));
maskn=zeros(size(mask));

for mm=1:max(mask(:)),
  % dilate (edge) mask
  tmpmask=(mask==mm);
  tmpmaskd=imdilate(tmpmask,ones(nn1,nn1));
  tmpmaskd=tmpmaskd&(~tmpmask);
  if mm>1, tmpmaskd=tmpmaskd&(~tmpmaskg); else, tmpmaskg=tmpmaskd; end;
  tmpmaskg=tmpmaskg|tmpmaskd;
  maskg(find(tmpmaskd))=mm;
  % erode (inside) mask
  tmpmaske=imerode(tmpmask,ones(nn1,nn1));
  if ~isempty(tmpmaske),
    maske(find(tmpmaske))=mm;
  end;
  % top f percent mask
  tmpmaskp=tmpmask.*im;
  tmpval=im(find(tmpmask));
  tmpthr=fthr*(max(tmpval)-min(tmpval))+min(tmpval);
  maskp(find(tmpmaskp>tmpthr))=mm;
  pthr(mm)=tmpthr;
  % top n mask
  tmpsort=sort(tmpval(:),1,'descend');
  if length(tmpsort)<=nthr,
    maskn(find(tmpmask))=mm;
  else,
    maskn(find(tmpmaskp>=tmpsort(nthr)))=mm;
  end;
end;

y.maskg=maskg;
y.maske=maske;
y.maskp=maskp;
y.maskn=maskn;

if nargout==0,
  figure(1), clf,
  subplot(221)
  im_overlay4(im,maskg)
  subplot(222)
  im_overlay4(im,maske)
  subplot(223)
  im_overlay4(im,maskp)
  subplot(224)
  im_overlay4(im,maskn)
  figure(2), clf,
  im_overlay4(im,mask)
  clear y
end;

