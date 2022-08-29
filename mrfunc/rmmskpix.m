function out=rmmskpix(mask)
%
% Usage ... modmask=rmmskpix(oldmask)
%
% Eliminates clicked pixels in a mask.
% 
%

figure(1);
clg;
show(mask);
xlabel('Press Return to finish');
ain=10;

while (ain),
  pixlist=round(ginput(ain));
  for n=1:length(pixlist),
    mask(pixlist(n,2),pixlist(n,1))=0;
  end;
  show(mask);
  ain=input('More deletions? (0-exit): ');
end;

show(mask);
axis('on');
title('Final Mask');

out=mask;

