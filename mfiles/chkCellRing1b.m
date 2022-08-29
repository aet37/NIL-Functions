function mask=chkCellRing1b(im1,nw,rc0,ang_range,thr)
% Usage ... msk=chkCellRing1b(im1,nw,rc0,ang_range,thr)
%
% Segment cell based on radius from the center location rc0

im1sz=size(im1);
mask=zeros(im1sz);

fig_flag=0;
det_flag=1;

if length(thr)==1, thr(2)=im1sz(1); end;
Nthr=thr(2);
if Nthr<1, Nthr=floor(im1sz(1)*Nthr); end;

if prod(size(im1))==prod(size(rc0)),
  [rc0x,rc0y]=find(rc0);
  rc0=[rc0x(:) rc0y(:)];
end;

for qq=1:size(rc0,1),
for oo=1:length(ang_range);
  [tmpla,tmplb,tmplc]=getRectImGrid2(im1,[nw 1],1,rc0(qq,:),ang_range(oo),1);
  for nn=1:size(tmplc,1), im1ln(nn)=im1(tmplc(nn,1),tmplc(nn,2)); end; 
  
  if det_flag,
    im1lnx=[1:length(im1ln)];
    im1lnfit=polyval(polyfit([1 mean(im1lnx(floor(length(im1lnx)/2):end))],[im1ln(1) mean(im1ln(floor(length(im1lnx)/2):end))],1),im1lnx);
    im1ln=im1ln-im1lnfit+mean(im1lnfit);
  end;
  
  tmplii=find(im1ln>thr(1));
  tmplii=tmplii(find(tmplii<=Nthr));
  if ~isempty(tmplii),
    tmpldi=find(diff(tmplii)>1);
    if ~isempty(tmpldi), 
      tmpli2=tmplii(1:tmpldi(1));
    else,
      tmpli2=tmplii;
    end;
  
    for nn=1:length(tmpli2), mask(tmplc(tmpli2(nn),1),tmplc(tmpli2(nn),2))=1; end;
    
    if fig_flag,
      clf,
      subplot(221), im_overlay4(im1,tmplb),
      subplot(222), im_overlay4(im1,mask), 
      subplot(212), plot([1:length(im1ln)],[im1ln(:) im1lnfit(:) ones(length(im1ln),1)*thr(1)],tmplii,im1ln(tmplii),'o',tmpli2,im1ln(tmpli2),'x')
      drawnow,
    end;
  end;
  clear tmpla tmplb tmplc 
  clear im1ln
end;


