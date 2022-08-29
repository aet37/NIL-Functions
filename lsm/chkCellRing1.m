function [ring_ok,yy]=chkCellRing1(im1,rwf_range,rrw,ctr_loc,rthr)
% Usage ... [ring_ok,ys]=chkCellRing1(im1,rwf_range,rrwf,ctr_loc,rthr)
%
% Tests to see if the object in im1 is ring-shaped, no segmentation

im1sz=size(im1);

grad_flag=0;
fig_flag=0;
if nargout==0, fig_flag=1; end;

if prod(size(rwf_range))==length(rwf_range),
  rwf_range=[rwf_range(:) rwf_range(:)]; 
end;
  
yy.im=im1;
yy.rwf_range=rwf_range;
yy.ctr0=ctr_loc;
yy.rthr=rthr;
 
for mm=1:size(rwf_range,1),
  tmpring=ring2(im1sz,rwf_range(mm)*im1sz,rrw,ctr_loc,0);
  if grad_flag,
    [im1gx,im1gy]=gradient(tmpim1);
    [tmpring1gx,tmpring1gy]=gradient(tmpring);
    im1g=sqrt(im1gx.^2+im1gy.^2);
    tmpring1g=sqrt(tmpring1gx.^2+tmpring1gy.^2);
    tmpxc=xcorr2(im1g/sum(im1g(:)),tmpring1g/sum(tmpring1g(:)));
    [tmp1x,tmp1y]=find(tmpxc==max(tmpxc(:)));
    tmpcc=corr(im1g(:),tmpring1g(:));
  else,
    tmpxc=xcorr2(im1,tmpring); 
    [tmp1x,tmp1y]=find(tmpxc==max(tmpxc(:)));
    %tmpxx=imMotDetect(im1,tmpring);
    %tmprc0=[ceil(im1sz(1)/2+tmpxx(1)) ceil(im1sz(2)/2+tmpxx(2))];
  end;
    
  tmprc0=[tmp1x-im1sz(1) tmp1y-im1sz(2)];
  if (tmprc0(1)>=im1sz(1)/2), tmprc0(1)=0; end;
  if (tmprc0(2)>=im1sz(2)/2), tmprc0(2)=0; end;
  if (tmprc0(1)<=-im1sz(1)/2), tmprc0(1)=0; end;
  if (tmprc0(2)<=-im1sz(2)/2), tmprc0(2)=0; end;
  
  tmpring=ring2(im1sz,rwf_range(mm)*im1sz,rrw,tmprc0,0);
  tmpcc=corr(im1(:),tmpring(:));

  if fig_flag,
    clf,
    subplot(221), show(im1),
    subplot(222), show(tmpring),
    subplot(223), show(im_super(im1,tmpring,0.3)),
    subplot(224), show(tmpxc), xlabel(num2str(tmpcc)),
    xlabel(sprintf('ctr=[%.1f %.1f]',tmprc0(1),tmprc0(2)));
    drawnow,
    disp(sprintf('  %d of %d (press enter)',mm,size(rwf_range,1)));
  end;

  yy.ring_all(:,:,mm)=tmpring;
  yy.xc_all(:,:,mm)=tmpxc;
  yy.cc_all(mm)=tmpcc;
  yy.ctr_all(mm,:)=tmprc0;
end;

[yy.cc,yy.ii]=max(yy.cc_all);
yy.ring=yy.ring_all(:,:,yy.ii);
yy.xc=yy.xc_all(:,:,yy.ii);
yy.ctr=yy.ctr_all(yy.ii,:);

yy.ring_ok=0;
if (yy.cc_all>rthr), yy.ring_ok=1; end;
ring_ok=yy.ring_ok;


