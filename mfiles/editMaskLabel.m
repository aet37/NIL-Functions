function y=editMaskLabel(mask,im,mask2)
% Usage ... mask_new=editMaskLabel(mask,im,mask2)
%
% Shows each mask label and allows editing for each label
% Adding only mask, it will enable label by label editing over a random
% image background. If im is added, it will overlay over that image. For
% each label, click outside when done to get a prompt in the matlab window.
% Right-click to flash the selection. 
% Adding mask2 will enable an operation between mask and mask2 as shown in
% the examples below.
%
% Ex. maskC2=editMaskLabel(maskC,avgim_intc(:,:,2));
%     mask2=editMaskLabel(mask1,'+',mask2);
%     mask1=editMaskLabel(mask,'relabel');
%     mask1=editMaskLabel(mask,im1);

nlabels=max(mask(:));

do_maskchar=0;

if ~exist('im','var'), im=[]; end;
if isempty(im), im=zeros(size(mask)); im=randn(size(mask)); end;
if ischar(im), do_maskchar=1; end;

if nargout==0,
  for mm=1:max(mask(:)),
    clf,
    im_overlay4(im,mask==mm),
    xlabel(sprintf('Overlay of Im and Mask #%d',mm)),
    drawnow,
    pause,
  end;
  return;
end;
  
if exist('mask2','var'),
  tmprelabel=0;
  if strcmp(im,'+'),
    nlabel2=max(mask2(:));
    disp(sprintf('  adding %d labels from mask2 into mask',nlabel2));
    for mm=1:nlabel2,
      if (sum(mask(find(mask2==mm))>0)/length(find(mask2==mm)))<0.51
        mask(find(mask2==mm))=nlabels+mm;
      else,
        tmprelabel=1;
        disp(sprintf('  warning: skipping label2 %d because of significant overlap',mm));
      end;
    end;
  elseif strcmp(im,'-'),
    nlabel2=max(mask2(:));
    disp(sprintf('  removing pixels in %d labels in mask2 from mask',nlabels2));
    for mm=1:nlabel2,
      mask(find(mask2==mm))=0;
    end;
  elseif strcmp(im,'relabel'),
    tmprelabel=1;
  else,
    disp('  warning: did not recognize mask operation');
    return,
  end;

  if tmprelabel,
    disp('  relabeling');
    tmpcnt=0; 
    tmpmask=zeros(size(mask));
    for mm=1:max(mask(:)),
      tmpii=find(mask==mm);
      if ~isempty(tmpii), tmpcnt=tmpcnt+1; tmpmask(tmpii)=tmpcnt; end;
    end;
    mask=tmpmask;
  end;
  
  y=mask;
  return,
end;

if do_maskchar,
  if strcmp(im,'relabel')|strcmp(im,'r'),
    tmpmask=zeros(size(mask));
    tmpcnt=0; 
    tmpmask_no=[];
    for mm=1:nlabels,
      tmpii=find(mask==mm);
      if ~isempty(tmpii),
        tmpcnt=tmpcnt+1;
        tmpmask(tmpii)=tmpcnt;
      else,
        tmpmask_no=[tmpmask_no mm];
      end;
    end;
    disp(sprintf('  relabeled mask (old=%d, new=%d)',nlabels,tmpcnt));
    mask=tmpmask;
    y=mask;
  end;
  return,
end;

clf;
tmpf=gcf;

tmpdone=0; mm=1;
tmpmask=mask;
while(~tmpdone),
  tmpmask1=(tmpmask==mm);
  tmpfnd=0; tmpupdate=0;
  disp(sprintf('  label #%d of %d',mm,nlabels));
  while(~tmpfnd),
    figure(tmpf), clf, im_overlay4(im,tmpmask1), title(sprintf('label #%d',mm)), drawnow,
    [tmpy,tmpx,tmpk]=ginput(1);
    tmpy=round(tmpy); tmpx=round(tmpx);
    %disp(sprintf('  [%d, %d, %d]',round(tmpy),round(tmpx),tmpk));
    if (tmpx<1)|(tmpy<1)|(tmpx>size(mask,2))|(tmpy>size(mask,1)), 
        tmpfnd=1;
    elseif isempty(tmpk), 
        tmpfnd=1; 
    else
        if (tmpk==3),
          for oo=1:2, 
            show(im), drawnow, 
            pause(0.5), 
            im_overlay4(im,tmpmask1), drawnow, 
            pause(0.5), 
            im_overlay4(im,tmpmask), drawnow, 
            pause(0.5),
          end;
        else
          if tmpmask1(tmpx,tmpy)==1, tmpmask1(tmpx,tmpy)=0; else, tmpmask1(tmpx,tmpy)=1; end;
        end
    end;
  end;
  tmpin=input(sprintf('  continue (%d)? [enter/n=next, gX=accept+goto, l=add-label-sel, r=redo, s=startover, A=add, x/X=done]: ',mm),'s');
  if isempty(tmpin), tmpupdate=1; 
  elseif strcmp(tmpin(1),'n'), tmpupdate=1; 
  elseif strcmp(tmpin(1),'g'), gg=str2num(tmpin(2:end)); tmpupdate=2;
  elseif strcmp(tmpin(1),'s'), tmpmask=mask; mm=1; tmpupdate=0;
  elseif strcmp(tmpin(1),'x'), tmpupdate=3; tmpdone=1;
  elseif strcmp(tmpin(1),'X'), tmpupdate=0; tmpdone=1;
  elseif strcmp(tmpin(1),'A'), mm=nlabels; nlabels=nlabels+1; tmpupdate=1;
  elseif strcmp(tmpin(1),'F')|strcmp(tmpin(1),'f'), 
      for oo=1:2, 
          show(im), drawnow, 
          pause(0.5), 
          im_overlay4(im,tmpmask1), drawnow, 
          pause(0.5), 
          im_overlay4(im,tmpmask), drawnow, 
          pause(0.5),
      end; 
      tmpupdate=0;
  elseif strcmp(tmpin(1),'l'),
    tmpupdate=4;
  elseif mm>=nlabels, tmpdone=1; tmpupdate=1;
  end
  if mm>=nlabels, tmpdone=1; end;
  if tmpupdate,
    tmpmask(find(tmpmask==mm))=0;
    tmpmask(find(tmpmask1))=mm;
    if tmpupdate==2,
      mm=gg;
    elseif tmpupdate==3,
      mm=mm;
    else,
      mm=mm+1;
    end;
  end;
  figure(tmpf), clf, im_overlay4(im,tmpmask), title('ALL (so far)'), drawnow, pause(0.2);
  if tmpupdate==4,
    tmpfnd2=0;
    while(~tmpfnd2),
      disp('  select region to separate, click outside when done...'),
      [tmpy,tmpx,tmpk]=ginput(1);
      tmpy=round(tmpy); tmpx=round(tmpx);
      if (tmpx<1)|(tmpy<1)|(tmpx>size(mask,2))|(tmpy>size(mask,1)), 
        tmpfnd2=1;
      elseif isempty(tmpk), 
        tmpfnd2=1;
      else,
        tmploc2=tmpmask(tmpx,tmpy);
        if tmploc2>0,
          tmpmask3=bwlabel(tmpmask==tmploc2);
          if max(tmpmask3(:))>1,
            tmploc22=tmpmask3(tmpx,tmpy);
            nlabels=nlabels+1;
            tmpmask(find(tmpmask3==tmploc22))=nlabels;
          end
        end;
      end;
    end
    figure(tmpf), clf, im_overlay4(im,tmpmask), title('ALL (so far)'), drawnow, pause(0.2);
  end
end;

y=tmpmask;

