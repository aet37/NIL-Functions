function fai_arccorr_v1(fname)
% Usage ... fai_arccorr_v1(fname)

nblk=50;
nrow=1;

% get and display first image
tmpstk1=tiffread2(fname,1);
im1=double(tmpstk1.data);
clear tmpstk1

imagesc(im1),
axis off, axis image, colormap gray, drawnow,

% select mask for correction
disp('select mask ROI for correction...')
msk=roipoly;

% get mask average time course
disp('getting mask ROI time course...');
nmsk=sum(sum(msk));
cnt=0; cnt2=0;
found=0;
while(~found),
  cnt=cnt+1;
  tmpstk=tiffread2(fname,(cnt-1)*nblk+1,cnt*nblk);
  if isempty(tmpstk),
    found=1;
    break;
  end;
  for mm=1:length(tmpstk),
    if isempty(tmpstk(mm)),
      found=1;
      break;
    end;
    cnt2=cnt2+1;
    tmpim=double(tmpstk(mm).data);
    msktc(cnt2)=sum(sum(tmpim.*msk))/nmsk;
  end;    
  if length(tmpmsk)~=nblk,
    found=1;
  end;
  clear tmpstk
end;
nfr=cnt2;
imdim=size(im1);

% show mask time course
plot(msktc)
drawnow,

% calculate coefficients, read data
disp('reading data, calculating coefficients...');
cnt=0;
for mm=1:floor(imdim(1)/nrow),
  cnt=cnt+1;
  cnt2=0;
  for nn=1:floor(nfr/nblk),
    tmpstk=tiffread2(fname,(nn-1)*nblk+1,nn*nblk);
    for oo=1:nblk,
      cnt2=cnt2+1;
      tmpim=double(tmpstk(oo).data);
      tmprow(:,:,cnt2)=tmpim((mm-1)*nrow+1:mm*nrow,:);
    end;
  end;
  % residual rows, residual frames?
  % calculate coefficients
  for nn=1:size(tmprow,1), for oo=1:size(tmprow,2),
    tmptc=squeeze(tmprow(nn,oo,:));
    tmpp=polyfit(msktc,tmptc,2);
    msk_map(nn+(cnt-1)*nrow,oo,:)=tmpp;
  end; end;
end;

% show maps
subplot(211)
show(msk_map(:,:,1))
subplot(212)
show(msk_map(:,:,2))

% write corrected data
for mm=1:floor(nfr/nblk),
  tmpstk=tiffread2(fname,(mm-1)*nblk+1,mm*nblk);
  for nn=1:nblk,
    tmpims(:,:,nn)=double(tmpstk(nn).data);
  end;
  clear tmpstk
  tmpx=([1:nblk]+(mm-1)*nblk);
  for nn=1:size(tmpims,1), for oo=1:size(tmpims,2),
    tmptc=squeeze(tmpims(nn,oo,:));
    tmpdd=polyval(squeeze(msk_map(nn,oo,:)),tmpx(:));
    tmpcorr(nn,oo,:)=tmptc-tmpdd+mean(tmpdd);
  end; end;
  if (mm==1), disp('writing corrected data...'); end;
  % write data
end;
% residual data
% write data
disp(sprintf('done...'))

