function y=myArc2d(imsz,ang1,ang2,rad)
% Usage ... y=myArc2d(imsz,ang1,ang2,rad)
%
% Create a mask spanning the arc between ang1 and ang2
% ang1 and ang2 must be in degrees
%
% Ex. myArc2d(128,-10,44,52)
% Ex. myArc2d(128,-10,44)

if ~exist('rad','var'), rad=[]; end;
if length(imsz)==1, imsz=[imsz imsz]; end;
if length(ang1)==2, ang1_orig=ang1; clear ang1 ; ang1=ang1_orig(1); ang2=ang1_orig(2); end;

if ang1<0, ang1=360+ang1; end;
if ang2<0, ang2=360+ang2; end;

if ang1>180, ang1=ang1-360; end;
if ang2>180, ang2=ang2-360; end;

[xx,yy]=meshgrid([0:imsz(1)-1]'-floor(imsz(1)/2),[0:imsz(2)-1]'-floor(imsz(2)/2));
dim=sqrt(xx.^2+yy.^2);
aim=atan2(yy,xx);

ang1=ang1*(pi/180);
ang2=ang2*(pi/180);

if ang1<=ang2,
 y=(aim>=ang1)&(aim<=ang2);
else,
 y=(aim>=ang2)&(aim<=ang1);
 y=(~y);
end

if ~isempty(rad),
  y=y&(dim<=rad);
end

if nargout==0,
  clf, 
  subplot(221), imagesc(aim), axis image, colormap jet, colorbar,
  subplot(222), imagesc(dim), axis image, colormap jet, colorbar,
  subplot(223), imagesc(y), axis image, colormap jet, colorbar,
  clear y
end;

