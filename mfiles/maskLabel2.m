function [labelstruc]=maskLabel2(mask1,mask1i,tc1,maskV,im)
% Usage ... [labelstruc]=maskLabel1(mask1,mask1i,tc1,maskV,im)
% 
% mask1 is the original mask, mask1i will indicate which are neuron or 
% astroglia

warning('off'),

figure(1), clf,

for mm=1:2,
  im_overlay4(im(:,:,1),mask1,256); drawnow; pause(0.3);
  im_overlay4(im(:,:,1),maskV,256); drawnow; pause(0.3);
end;

disp(sprintf('  press enter to start...')), pause,

for mm=1:max(maskV(:)),
  figure(1), clf,
  im_overlay4(im(:,:,1),maskV==mm), 
  title(sprintf('  Select 1ry NEURONS for vessel %d',mm));
  disp(sprintf('  Select 1ry NEURONS for vessel %d',mm));
  drawnow,
  pause(1),
  tmpmask=zeros(size(mask1));
  tmpi=find(mask1i(:,1)==1);
  for nn=1:length(tmpi), tmpmask(find(mask1==tmpi(nn)))=1; end;
  cnt=0; iN1{mm}=[];
  im_overlay4(im(:,:,1),tmpmask), drawnow,
  tmpfound=0;
  while(~tmpfound),
    tmploc=round(ginput(1));
    %disp(sprintf('  [%d, %d]',tmploc(1),tmploc(2)));
    if (tmploc(2)>size(im(:,:,1),1))|(tmploc(2)<1)|(tmploc(1)>size(im(:,:,1),2))|(tmploc(1)<1),
      tmpfound=1;
    else,
      tmpii=mask1(tmploc(2),tmploc(1));
      if tmpii>0,
        if tmpmask(tmploc(2),tmploc(1)),
          tmpmask(find(mask1==tmpii))=2;
          cnt=cnt+1;
          iN1{mm}(cnt)=tmpii;
          im_overlay4(im(:,:,1),tmpmask), 
          title(sprintf('  Select 1ry NEURONS for vessel %d',mm));
          drawnow,
        end;
      end;
    end;
  end;
  nN1(mm)=cnt;

  clf,
  im_overlay4(im(:,:,1),maskV==mm), 
  title(sprintf('  Select 2ry NEURONS for vessel %d',mm));
  disp(sprintf('  Select 2ry NEURONS for vessel %d',mm));
  drawnow,
  pause(1),
  cnt=0; iN2{mm}=[];
  im_overlay4(im(:,:,1),tmpmask), drawnow,
  tmpfound=0;
  while(~tmpfound),
    tmploc=round(ginput(1));
    if (tmploc(2)>size(im(:,:,1),1))|(tmploc(2)<1)|(tmploc(1)>size(im(:,:,1),2))|(tmploc(1)<1),
      tmpfound=1;
    else,
      tmpii=mask1(tmploc(2),tmploc(1));
      if tmpii>0,
        if tmpmask(tmploc(2),tmploc(1)),
          tmpmask(find(mask1==tmpii))=3;
          cnt=cnt+1;
          iN2{mm}(cnt)=tmpii;
          im_overlay4(im(:,:,1),tmpmask); 
          title(sprintf('  Select 2ry NEURONS for vessel %d',mm));
          drawnow,
        end;
      end;
    end;
  end;
  nN2(mm)=cnt;

  clf,
  im_overlay4(im(:,:,1),maskV==mm), 
  title(sprintf('  Select 1ry ASTROGLIA for vessel %d',mm));
  disp(sprintf('  Select 1ry ASTROGLIA for vessel %d',mm));
  drawnow,
  pause(1),
  tmpmask=zeros(size(mask1));
  tmpi=find(mask1i(:,1)==2);
  for nn=1:length(tmpi), tmpmask(find(mask1==tmpi(nn)))=2; end;
  cnt=0; iA1{mm}=[];
  im_overlay4(im(:,:,1),tmpmask), drawnow,
  tmpfound=0;
  while(~tmpfound),
    tmploc=round(ginput(1));
    if (tmploc(2)>size(im(:,:,1),1))|(tmploc(2)<1)|(tmploc(1)>size(im(:,:,1),2))|(tmploc(1)<1),
      tmpfound=1;
    else,
      tmpii=mask1(tmploc(2),tmploc(1));
      if tmpii>0,
        if tmpmask(tmploc(2),tmploc(1)),
          tmpii=mask1(tmploc(2),tmploc(1));
          tmpmask(find(mask1==tmpii))=4;
          cnt=cnt+1;
          iA1{mm}(cnt)=tmpii;
          im_overlay4(im(:,:,1),tmpmask); 
          title(sprintf('  Select 1ry ASTROGLIA for vessel %d',mm));
          drawnow,
        end;
      end;
    end;
  end;
  nA1(mm)=cnt;

  clf,
  im_overlay4(im(:,:,1),maskV==mm), 
  title(sprintf('  Select 2ry ASTROGLIA for vessel %d',mm));
  disp(sprintf('  Select 2ry ASTROGLIA for vessel %d',mm));
  drawnow,
  pause(1),
  cnt=0; iA2{mm}=[];
  im_overlay4(im(:,:,1),tmpmask), drawnow,
  tmpfound=0;
  while(~tmpfound),
    tmploc=round(ginput(1));
    if (tmploc(2)>size(im(:,:,1),1))|(tmploc(2)<1)|(tmploc(1)>size(im(:,:,1),2))|(tmploc(1)<1),
      tmpfound=1;
    else,
      tmpii=mask1(tmploc(2),tmploc(1));
      if tmpii>0,
        if tmpmask(tmploc(2),tmploc(1)),
          tmpmask(find(mask1==tmpii))=5;
          cnt=cnt+1;
          iA2{mm}(cnt)=tmpii;
          im_overlay4(im(:,:,1),tmpmask);
          title(sprintf('  Select 2ry ASTROGLIA for vessel %d',mm));
          drawnow,
        end;
      end;
    end;
  end;
  nA2(mm)=cnt;
end;

labelstruc.nN1=nN1;
labelstruc.nN2=nN2;
labelstruc.nA1=nA1;
labelstruc.nA2=nA2;
labelstruc.iN1=iN1;
labelstruc.iN2=iN2;
labelstruc.iA1=iA1;
labelstruc.iA2=iA2;

