function y=im_overlay_match(im1,mask1,im2,mask2)
% Usage ... y=im_overlay_match(im1,mask1,im2,mask2)

tmph1=gcf; clf,
tmph2=figure, clf,

cnt=0;
tmpok=0;
while(~tmpok),
    figure(tmph1), clf,
    im_overlay4(im1,mask1),
    drawnow,
    figure(tmph2), clf,
    im_overlay4(im2,mask2),
    drawnow,
    
    tmpok1=0;
    while(~tmpok1),
        figure(tmph1),
        xlabel('select location 1'),
        [tmpy1,tmpx1]=ginput(1);
        tmpx1=round(tmpx1);
        tmpy1=round(tmpy1);
        if (tmpx1<0)|(tmpy1<0)|(tmpy1>size(im1,1))|(tmpx1>size(im1,2)),
            tmpok=1;
            break;
        end
        tmpi1=mask1(tmpx1,tmpy1);
        if tmpi1>0, tmpok1=1; end;
    end
    
    if tmpok==1, break; end,
    
    tmpok2=0;
    while(~tmpok1),
        figure(tmph2),
        xlabel('select location 2'),
        [tmpy2,tmpx2]=ginput(1);
        tmpx2=round(tmpx2);
        tmpy2=round(tmpy2);
        if (tmpx2<0)|(tmpy2<0)|(tmpy2>size(im1,1))|(tmpx2>size(im1,2)),
            tmpok=1;
            break;
        end
        tmpi2=mask2(tmpx2,tmpy2);
        if tmpi2>0, tmpok2=1; end;
    end
 
    if tmpok==1, break; end,
    
    cnt=cnt+1;
    y(cnt,:)=[tmpi1 tmpi2];
end

    