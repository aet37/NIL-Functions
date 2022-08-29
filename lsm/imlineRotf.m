function [y,tmpim]=imlineRotf(rang,im,rtype,parms)
% Usage ... y=imlineRotf(rang,im,rtype,parms)

% parmaters: [dx(2)]

% test of methods to measure slope of lines in an image
% 1. SVD (square matrix is preferred)
% 2. Proj STDEV
% 3. Proj FT
% 4. Radon transform

redf=0.5;
do_invert=1;

if rtype==4,
  tmprad=radon(im',rang);
  tmprad1=var(tmprad);
  y=tmprad1;
  tmpim=tmprad;
else,
  if nargin<4, dx=[0.2 0.2]; else, dx=parms(1:2); end;
  rw=floor(size(im)*redf);
  aloc=floor(size(im)/2)+1;
  tmpim=getRectImGrid(im,rw,dx,aloc,rang)';
end;
if rtype==1,
  [tmpa,tmpb,tmpc]=svd(tmpim);
  tmpbtr=sum(diag(tmpb));
  tmpbmax=max(diag(tmpb));
  tmpbrat=tmpbmax/tmpbtr;
  y=tmpbrat;
elseif rtype==2,
  tmpimf=fft2(tmpim);
  tmpfsum=sum(abs(tmpimf.*tmpimf),1);
  y=tmpfsum(1);
elseif rtype==3,
  tmpproj=mean(tmpim,2);
  tmpstd=var(tmpproj);
  y=tmpstd;
end;

if do_invert,
  y=1/y;
end;

%disp(sprintf('  %.4f (%d)',y,rtype));
%keyboard,
