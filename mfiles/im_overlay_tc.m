function im_overlay_tc(im,mask,tc_mask,n_tcs)
% Usage ... im_overlay_tc(tc,mask,tc_mask,n_tcs)
%
% Displays two figures, one with an image and its overlay, the 
% other with the matching time series

do_dispmany=0;

if iscell(im),
  do_dispmany=1;
  im_many=im{2:end};
  im_orig=im;
  clear im
  im=im_orig{1};
end

tmph1=gcf; clf,
tmph2=figure, clf,

tmpok=0;
while(~tmpok),
    figure(tmph1),
    if do_dispmany,
        for mm=1:2,
            for nn=1:length(im_ov),
                show(im_ov{nn}),
                drawnow, pause(0.1),
            end
            im_overlay4(im,mask),
            drawnow, pause(0.1),
        end
    else,
        im_overlay4(im,mask),
        drawnow,
    end
    title(sprintf('select %d locations',n_tcs)),
    [tmpy,tmpx]=ginput(n_tcs);
    tmpy=round(tmpy); 
    tmpx=round(tmpx);
    if (tmpy(1)<0)|(tmpx(1)<0)|(tmpy>size(im,1))|(tmpx>size(im,2)),
        tmpok=1;
    else,
        tmptc=[];
        for mm=1:n_tcs, 
            tmpii(mm)=mask(tmpx,tmpy);
            disp(sprintf('  %d: %d',mm,tmpii(mm)));
            if tmpii(mm)>0,
                tmptc=[tmptc tc_mask(:,tmpii(mm))];
            end
        end
        figure(tmph2),
        plotmany(tmptc), drawnow,
    end
end
