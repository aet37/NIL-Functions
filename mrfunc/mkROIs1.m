function rois=mkROIs1(stk,mask,thr,rtype)
% Usage ... y=mkROIs1(stk_ims,mask,thr,rtype)

verbose_flag=0;
if nargout==0,
  verbose_flag=1;
end;

rois=zeros(size(stk(:,:,1)));
for mm=1:size(stk,3),
  % should make individual rois and then rank order by max thr or mean thr
  % or order backwards?
  tmpim=stk(:,:,mm);
  tmpim=im_smooth(tmpim,2);
  tmpim2=tmpim.*mask;
  tmpthr2=max(tmpim2(:));
  tmpmsk=(tmpim2>tmpthr2*thr);
  tmpmax(mm)=tmpthr2;
  tmpmasks(:,:,mm)=tmpmsk;
  if verbose_flag,
    subplot(221), show(tmpim),
    subplot(222), show(tmpim2),
    subplot(224), show(tmpmsk),
    drawnow, disp(sprintf('  mask#%d...',mm)), pause,
  end;
end;

[tmps,tmpi]=sort(tmpmax(:),1,'ascend');
for mm=1:size(tmpmasks,3),
  rois(find(tmpmasks(:,:,tmpi(mm))))=tmpi(mm);
end;

if verbose_flag,
  clf, imagesc(rois), axis image, colormap jet,
  clear rois
end;

