function showroitc(im,mask,tc)
% Usage showroitc(im,roimask,roitc)

figure(1)
subplot(212)
plot(mean(tc,2)), grid('on'), axis('tight'),
subplot(211)
im_overlay4(im,mask>0,64);

found=0;
while(~found)
  [tmpy,tmpx,tmpb]=ginput(1);
  tmpx=round(tmpx); tmpy=round(tmpy);
  if tmpb==1,
    if (tmpx<1)|(tmpx>size(im,1)),
      found=1;
    elseif (tmpy<1)|(tmpy>size(im,2)),
      found=1;
    else,
      tmproi=mask(tmpx,tmpy);
      if tmproi,
        tmpmask=(mask>0)+(mask==tmproi);
        figure(1)
        subplot(212)
        plot(tc(:,tmproi)), grid('on'), axis('tight'),
        title(sprintf('roi= %d',tmproi));
        subplot(211)
        im_overlay4(im,tmpmask,64);
        drawnow,
        disp(sprintf('  roi= %d',tmproi));
      end;
    end;
  else,
    found=1;
  end;
end;

