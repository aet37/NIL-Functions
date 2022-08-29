function [y,xx]=imFlipSelect(im1,xx);
% Usage y=imFlipSelect(im1,x_or_refim)

y=im1;
if length(xx)>2,
  figure(1), clf,
  tmpok=0;
  im2=xx;
  xx=[0 0];
  while(~tmpok),
    subplot(121), show(im2), xlabel('Reference'),
    subplot(122), show(y),
    drawnow,
    tmpin=input('  select (0/enter-done, 1-flipLR, 2-flipUD, 9-reset): ');
    if isempty(tmpin),
      tmpok=1;
    elseif tmpin==1,
      y=fliplr(y); xx(1)=1;
    elseif tmpin==2,
      y=flipud(y); xx(2)=1;
    elseif tmpin==9,
      y=im1; xx=[0 0];
    elseif tmpin==0,
      tmpok=1;
    end;
  end;
else,
  if xx(1), y=fliplr(y); end;
  if xx(2), y=flipud(y); end;
end;

