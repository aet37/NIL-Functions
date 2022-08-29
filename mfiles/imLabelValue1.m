function [y,yl]=imLabelValue1(im,mask,parm)
% Usage ... y=imLabelValue1(im,mask,parm)

if ~exist('parm','var'), parm=[]; end;
    
if iscell(im),
    im1=im{2};
    im0=im{1};
    clear im
    im=im0;
    parm='select';
else,
    im1=im;
end

if ischar(parm),
  tmph=gcf;
  figure(tmph),
  im_overlay4(im1,mask)

  [tmpy,tmpx]=ginput;
  tmpy=round(tmpy); tmpx=round(tmpx);

  for mm=1:length(tmpy),
      yl(mm)=mask(tmpx(mm),tmpy(mm));
      y(mm)=mean(im(find(mask==yl(mm))));
  end;
else,
  for mm=1:max(mask(:)),
      y(mm)=mean(im(find(mask==mm)));
  end
end

  
if nargout==0,
  [yl(:), y(:)],
  clear y yl
end
