function y=vesselSegment1(im,parms)
% Usage ... y=vesselSegment1(im,parms)
%
% parms=[thrf=0.1 nseg_est=20]

thrf=parms(1);
nseg=parms(2);

thr=0.1*max(max(im));
ee1=edge(im,'canny',[0.05 0.15],3);
dd1=bwdist(im>thr);
dd2=bwdist(im<thr);
wd1=watershed(dd1);
wd2=watershed(dd2);
msk=real(im_smooth(im,2))>thr;

treeIm=(wd2==0)|imregionalmax(dd1);

[tmpa,mycwd]=unix('pwd');
cd /Users/towi/matlab/ncut_multiscale_1_5
init,

dd1sm=real(im_smooth(dd1,4));
segCl=ncut_multiscale(dd1sm,nseg);
unix(sprintf('cd %s',mycwd'));

nsegCl=max(max(segCl));
cnt1=0; vsegIm=zeros(size(segCl));
for mm=1:nsegCl,
  ii=find(segCl==mm);
  ii2=find(msk(ii));
  if ~isempty(find(msk(ii))), 
    cnt1=cnt1+1;
    vsegIm(ii)=cnt1;
  end;
end;

y.im=im;
y.parms=parms;
y.nseg=cnt1;
y.segCl=segCl;
y.segIm=vsegIm;
y.edgeIm=ee1;
y.treeIm=treeIm;


