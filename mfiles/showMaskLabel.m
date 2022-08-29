function maskall=showMaskLabel(mask,im)
% Usage ... maskall=showMaskLabel(mask,im)


if iscell(mask),
  maskall=zeros(size(mask{1}));
  for mm=1:length(mask), maskall(find(mask{mm}>0))=mm; end;
  figure(2), clf, im_overlay4(im,maskall), drawnow,
  
  figure(1), clf,
  if nargin==1, im=zeros(size(mask{1})); end;
  for mm=1:length(mask),
    im_overlay4(im,mask{mm}), xlabel(num2str(mm)), drawnow, pause,
  end;
  
else,
  maskall=zeros(size(mask(:,:,1)));
  for mm=1:length(mask), maskall(find(mask(:,:,mm)>0))=mm; end;
  figure(2), clf, im_overlay4(im,maskall), drawnow,

  if nargin==1, im=zeros(size(mask(:,:,1))); end;
  for mm=1:size(mask,3),
    im_overlay4(im,mask(:,:,mm)), xlabel(num2str(mm)), drawnow, pause,
  end;

end;

if nargout==0,
  clear maskall
end
