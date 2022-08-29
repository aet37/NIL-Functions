function y=mkRowPanels(data,parms,wl,cropii,writename)
% Usage ... y=mkRowPanels(data,{parms,ii},wl,cropii,writename)
% 
% parms=[npanels nimavg sm_w nbin transp_flag]

if nargin<5, writename=[]; end;
if nargin<4, cropii=[]; end;
if nargin<3, wl=[]; end;
if nargin<2, parms=[]; end;

if isempty(parms),
  parms=[];
end;
if isempty(wl),
  wl=[min(data(:)) max(data(:))];
end;
if isempty(cropii),
  cropii=[1 size(data,2) 1 size(data,1)];
end;
if isempty(writename),
  do_write=0;
end;

smw=parms(1);
nbin=parms(2);
transpflag=parms(3);

imseq=[];
for mm=1:npanels,
  imseq(:,:,mm)=mean(data(:,:,[0:nims-1]+ii(mm)),3);
  imseq(:,:,mm)=imseq(:,:,mm)/mean(mean(imseq(:,:,mm)))-1;
end;
impan=[];
for mm=1:npanels,
  tmpim=imseq(:,:,mm);
  tmpim=tmpim(cropii(1):cropii(2),cropii(3):cropii(4));
  if nbin>1, tmpim=imbin(tmpim,nbin); end;
  if smw>0, tmpim=im_smooth(tmpim,smw); end;
  if transpflag, tmpim=tmpim'; end;
  impan=[impan tmpim];
end;

show(impan,wl), drawnow,

if do_write,
  imwrite(imwlevel(impan,wl,1),tmpname,'JPEG','Quality',100);
end;

%imseq=[]; for mm=1:10, imseq(:,:,mm)=mean(avgim(:,:,[1:4]+(mm-1)*4),3); if mm==1, tmpavg=mean(mean(imseq(:,:,1))); end; imseq(:,:,mm)=imseq(:,:,mm)/tmpavg-1; end;
%imseq=[]; for mm=1:10, imseq(:,:,mm)=mean(avgim(:,:,[1:4]+(mm-1)*4),3); imseq(:,:,mm)=imseq(:,:,mm)/mean(mean(imseq(:,:,mm)))-1; end;
%impan=[]; for mm=1:10, impan=[impan im_smooth(imbin(imseq(:,:,mm),2),1)']; end;
%imwrite(imwlevel(im_smooth(imbin(impan,2),1),[-1 1]*0.003,1),'samplefig_ois620_dyn1fl_nc_rowpanel.jpg','JPEG','Quality',100)

