function y=showSeedCorr(stk,im,nn)
% Usage ... y=showSeedCorr(stk,im,nn)

if nargin==1, nn=0; im=1; end;
if nargin==2, nn=0; end;
if ~exist('ntype'), ntype='disk'; end;

stk=squeeze(stk);

do_dilate=0;
if nn>0, do_dilate=1; end;

if length(im)==1, im=stk(:,:,im); end;
if ischar(im), if strcmp(im,'avg'), im=mean(stk,3); end; end;
imdim=size(im);

close all

hh1=figure;
hh2=figure;
hh3=figure;
do_showim=1;
do_wl=0;
xloc=[]; yloc=[];
found=0;
while(~found),
  % select location
  figure(hh1),
  %subplot(211)
  if do_showim,
    show(im), drawnow,
    do_showim=0;
  end;
  [tmpy,tmpx,tmpbut]=ginput(1);
  tmpx=round(tmpx); tmpy=round(tmpy);
  disp(sprintf(' [%d,%d]= %d',tmpx,tmpy,tmpbut));
  tmpok=1;
  if (tmpx<1)|(tmpx>imdim(1)), tmpok=0; found=1; end;
  if (tmpy<1)|(tmpy>imdim(2)), tmpok=0; found=1; end;
  if (tmpok),
    if do_dilate,
      tmpmask=zeros(size(im));
      tmpmask(tmpx,tmpy)=1;
      tmpmask=imdilate(tmpmask,strel(ntype,nn));
      for nn=1:size(stk,3), tmpref(nn)=sum(sum(stk(:,:,nn).*tmpmask)); end;
      tmpref=tmpref/sum(sum(tmpmask));
    else,
      tmpmask=zeros(size(im));
      tmpmask(tmpx,tmpy)=1;
      tmpref=squeeze(stk(tmpx,tmpy,:));
    end;
    tmpmask=double(tmpmask);
    tmpcor=OIS_corr2(stk,tmpref);
    if do_wl==0, tmpwl=[min(min(tmpcor)) max(max(tmpcor))]; end;
    figure(hh1),
    im_overlay4(im,tmpmask);
    drawnow,
    figure(hh2),
    %subplot(212),
    imagesc(tmpcor,[-1 1]), axis('image'), colormap(jet), colorbar,
    xloc=tmpx; yloc=tmpy;
    drawnow;
    %figure(1), show(im_smooth(tmpcor,1).^2,[0 0.8]), colormap('jet'), drawnow,
    figure(hh3),
    plot(tmpref), axis('tight'),
    drawnow,
  end;
  if (tmpok)&(tmpbut==3),
    tmpwl=input('  enter [min max]= ');
    do_wl=1;
    figure(hh2),
    %subplot(212)
    show(tmpcor,tmpwl)
    drawnow, pause(1);
  end; 
end;

if nargout==1,
  y.mask=tmpmask;
  y.pix=[yloc xloc];
  y.cor=tmpcor;
  y.ref=tmpref;
end;

%close(hh1) 
%close(hh2)

