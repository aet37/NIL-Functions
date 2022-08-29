function [y,ys]=maskRefine1(mask,ims,parms,masktype)
% Usage ... y=maskRefine1(mask,ims,parms,masktype)
%
% Refinement of mask ROIs from images where ims are a stack of images
% This funciton assumes the mask is a labeled mask
% Parameters are: parms=[smw rco rww thrf]
% smoothing_width radial_extent and transition_width, fractional threshold
% for the correlation cutoff
% If a last argument is added, you can specify mask is a local-min mask
% where each hit represents the width of each feature
%
% Ex. y=maskRefine1(mask,ims,[1 8 2 0.7]);
%     y=maskRefine1(imlog.imlminn,ims,[1 8 2 0.7],'lminw');


do_figure=1;
if nargout==0, do_figure=1; end;

if nargin<3, parms=[1 8 2 0.7]; end;

ims=squeeze(ims);
avgim=mean(ims,3);

[xx,yy]=meshgrid([1:size(avgim,1)]',[1:size(avgim,2)]);

smw=parms(1);
rco=parms(2);
rww=parms(3);
thrf=parms(4);

if exist('masktype','var'),
  if strcmp(masktype,'lminw')|strcmp(masktype,'localminw')|strcmp(masktype,'lmin'),
    tmpthr=min(avgim(:))+0.05*(max(avgim(:))-min(avgim(:)));
    tmpcnt=0;
    tmpmask=zeros(size(ims,1),size(ims,2));
    [tmpir,tmpic]=find(abs(mask)>0);
    for mm=1:length(tmpir),
      tmprco=2*mask(tmpir(mm),tmpic(mm));
      tmprww=tmprco/5;
      tmprr=sqrt((xx-tmpic(mm)).^2+(yy-tmpir(mm)).^2);
      tmpr1=1./(1+exp((tmprr-tmprco)/tmprww));
      tmpval=mean(avgim(find(tmpr1>0.1)));
      if tmpval>tmpthr, 
        tmpcnt=tmpcnt+1; 
        tmpmask(find(tmpr1>0.1))=tmpcnt; 
      else
        disp(sprintf('  excluding %d: %f < %f',mm,tmpval,tmpthr));
      end;
      if do_figure,
        figure(1), clf,
        subplot(121), imagesc(imdilate(mask==mask(tmpir(mm),tmpic(mm)),ones(3,3))), axis image, colormap jet,
        subplot(122), imagesc(tmpmask), axis image, colormap jet, 
        drawnow,
      end
    end
    mask_orig=mask;
    mask=tmpmask;
    clear tmpmask
  end
end

tc=getStkMaskTC(ims,mask);

nlab=max(mask(:));
disp(sprintf('  #labels= %d',nlab));

tmpmasknew=zeros(size(mask));
tmpmasknot=zeros(size(mask));
for mm=1:nlab,
    tmpmask=(mask==mm);
    if sum(tmpmask(:)),
      tmpcm=imCenterMass(avgim,tmpmask);
      tmprim=OIS_corr2(ims,tc.atc(:,mm));
      tmprr=sqrt((xx-tmpcm(2)).^2+(yy-tmpcm(1)).^2);
      tmpr1=1./(1+exp((tmprr-rco)/rww));
      tmprim1=im_smooth(tmprim,smw).*tmpr1;
      tmpval=sum(tmprim1(:).*tmpmask(:))/sum(tmpmask(:));
      tmpthr=tmpval*thrf;
      tmpmask2=tmprim1>tmpthr;
      tmpmask2not=(tmpr1>0.02)&(~tmpmask2);
    
      if do_figure,
      disp(sprintf('  lab#%02d: avg=%f, thr=%f',mm,tmpval,tmpthr));

      figure(1), clf, 
      subplot(221), im_overlay4(avgim,mask), 
      subplot(222), im_overlay4(avgim,tmpmask), 
      if mm>1, subplot(223), im_overlay4(avgim,tmpmasknew), end;
      drawnow, 
      
      figure(2), clf,
      subplot(221), imagesc(tmprim), axis image, colormap jet, colorbar, 
      subplot(222), imagesc(tmpr1), axis image, colormap jet, colorbar,
      subplot(223), imagesc(tmprim1), axis image, colormap jet, colorbar,
      subplot(224), imagesc(tmpmask2), axis image, colormap jet, 
      drawnow, 
      %pause, 
      end;
      
      tmpmasknew(find(tmpmask2))=mm;
      tmpmasknot(find(tmpmask2not))=mm;
      tmpthrall(mm)=tmpthr;
      tmpcmall(mm,:)=tmpcm;
    else,
      if do_figure, disp(sprintf('  lab#%02d empty',mm)); end;
    end;
end

y=tmpmasknew;

ys.parms=parms;
ys.mask_orig=mask;
ys.avgim=avgim;
ys.thr=tmpthrall;
ys.cm=tmpcmall;
ys.mask_new=tmpmasknew;
ys.mask_not=tmpmasknot.*(tmpmasknew<0.5);
ys.mask_not_all=(~(tmpmasknew>0));
ys.mask_not_all=(~(tmpmasknew>0)).*(imwlevel(avgim,[],1)>0.1);

if nargout==1,  
  y=ys;
  clear ys
elseif nargout==0,
  clear y ys
end

