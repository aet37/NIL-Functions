function y=twop_imfilt(x,mfp,smp,hcf)
% Usage ... y=twop_imfilt(x,mfp,smp,hcf)
%
% median filter uses medfilt2 so use neighborhood size
% smoothing uses im_smooth so use smoother width in pixels
% hcf uses homocor so use neighborhood in pixels
% use [] or 0 to skip
%
% Ex. zdataf=twop_filt(zdata,3,0,{16});
%     tdataf=twop_filt(tdata,3,0.5,12);


if ~exist('mfp','var'), mfp=[]; end;
if ~exist('smp','var'), smp=[]; end;
if ~exist('hcf','var'), hcf=-1; end;

if isempty(mfp), mfp=0; end;
if isempty(smp), smp=0; end;

xdim=size(x);
if length(mfp)==1; mfp=[mfp mfp]; end;

if iscell(hcf), 
  if (length(hcf)==1)
    tmphcf=hcf{1};
    clear hcf
    hcf=tmphcf;
    if length(hcf)==1, hcf=hcf*ones(xdim(3:end)); end;    
  end;
end;

if nargout==0,
  if length(xdim)==4, x=x(:,:,:,1);
  else, x=x(:,:,1);
  end;
  xdim=size(x);
end;

y=x;
if length(xdim)==4,
  if hcf==-1,
    avgim=mean(x,4);
    hcim=ones(size(avgim));
  else
    avgim=mean(x,4);
    for oo=1:size(avgim,3),
      if length(hcf)==size(avgim,3),
        [avgimf(:,:,oo),hcim(:,:,oo)]=homocorOIS(avgim(:,:,oo),hcf(oo));
      elseif length(hcf)==1,
        [avgimf(:,:,oo),hcim(:,:,oo)]=homocorOIS(avgim(:,:,oo),hcf);
      elseif size(hcf,3)>1,
        hcim(:,:,oo)=hcf(:,:,oo);
      else,
        hcim(:,:,oo)=hcf;
      end;
    end;
  end;
  
  for nn=1:xdim(4), for mm=1:xdim(3),
    if mfp>0, y(:,:,mm,nn)=medfilt2(y(:,:,mm,nn),mfp); end;
    if smp>0, y(:,:,mm,nn)=im_smooth(y(:,:,mm,nn),smp); end;
    y(:,:,mm,nn)=hcim(:,:,mm).*y(:,:,mm,nn);
  end; end;

elseif length(xdim)==5,
  if hcf==-1,
    avgim=mean(x,5);
    hcim=ones(size(avgim));
  else
    avgim=mean(x,5);
    for oo=1:size(avgim,3), for pp=1:size(avgim,4),
      if length(hcf)==size(avgim,3),
        [avgimf(:,:,oo,pp),hcim(:,:,oo,pp)]=homocorOIS(avgim(:,:,oo,pp),hcf(oo));
      elseif length(hcf)==1,
        [avgimf(:,:,oo,pp),hcim(:,:,oo,pp)]=homocorOIS(avgim(:,:,oo,pp),hcf);
      elseif size(hcf,3)>1,
        hcim(:,:,oo,pp)=hcf(:,:,oo);
      else,
        hcim(:,:,oo,pp)=hcf;
      end;
    end; end;
  end;
  
  for oo=1:xdim(5), for nn=1:xdim(4), for mm=1:xdim(3),
    if mfp>0, y(:,:,mm,nn,oo)=medfilt2(y(:,:,mm,nn,oo),mfp); end;
    if smp>0, y(:,:,mm,nn,oo)=im_smooth(y(:,:,mm,nn,oo),smp); end;
    y(:,:,mm,nn,oo)=hcim(:,:,mm,nn).*y(:,:,mm,nn,oo);
  end; end; end;

elseif length(xdim)==3,
  do_many_hcf=0;
  if (length(hcf)==1)&(hcf>100*eps),
    [avgimf,hcim]=homocorOIS(avgim,hcf);
  elseif length(hcf)==xdim(3),
      hcim=zeros(xdim(1:3));
      do_many_hcf=1;
      for mm=1:xdim(3),
        disp(sprintf('  calc hcim with %.1f',hcf(mm)));
        [avgimf,hcim(:,:,mm)]=homocorOIS(y(:,:,mm),hcf(mm));
      end;
  else,
      hcim=hcf;
  end;
  
  for mm=1:xdim(3),
    if mfp>0, y(:,:,mm)=medfilt2(y(:,:,mm),mfp); end;
    if smp>0, y(:,:,mm)=im_smooth(y(:,:,mm),smp); end;
    if do_many_hcf,
      %show(hcim(:,:,mm)), drawnow,
      y(:,:,mm)=hcim(:,:,mm).*y(:,:,mm);
    else,
      y(:,:,mm)=hcim.*y(:,:,mm);
    end;
  end;
  
else,
  % assume only single image
  do_many_hcf=0;
  if hcf==-1,
    hcim=ones(xdim(1:2));
  elseif length(hcf)==1,
    [avgimf,hcim]=homocorOIS(x(:,:,1),hcf);
  else,
    hcim=hcf;
  end;
  
  if mfp>0, y(:,:,1)=medfilt2(y(:,:,1),mfp); end;
  if smp>0, y(:,:,1)=im_smooth(y(:,:,1),smp); end;
  if do_many_hcf,
      %show(hcim(:,:,mm)), drawnow,
  else,
      y(:,:,1)=hcim.*y(:,:,1);
  end;
end;

if nargout==0,
  show(y),
  drawnow,
  clear y
end;
