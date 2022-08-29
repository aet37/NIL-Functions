function [sIm,yout,ROIs]=manyRadROIs(im,inv_flag,imaxis,parms,optangle_flag)
% Usage ... [supIm,ang_yout,ROIs]=manyRadROIs(im,inv_flag,im_axis,parms,optangle_flag)
%
% Mouse-driven selection of slit ROIs for vessel diameter measurement
% parms=[nY dxy rangeAng pOrd optflag]  def=[4 0.2 25 4 1]
%
% Ex. rad1=manyRadROIs(avgim(:,:,1),1);
%     rad1=manyRadROIs({avgim(:,:,1),myIm1},1,[],[],1);


if ~exist('parms'), parms=[]; end;
if ~exist('imaxis'), imaxis=[]; end;
if ~exist('inv_flag'), inv_flag=[]; end;
if ~exist('optangle_flag'), optangle_flag=0; end;

if isempty(parms), 
  parms=[4 0.2 25 4]; 
elseif length(parms)==1,
  parms=[parms 0.2 25 4];
elseif length(parms)==2,
  parms=[parms 25 4];
elseif length(parms)==3,
  parms=[parms 4];
end;

do_overlay=0;

if iscell(im),
  im_orig=im;
  clear im
  im=im_orig{1};
  if length(im_orig)==2,
    imov{1}=im_orig{2};
  else,
    imov=im_orig{2:end};
  end
  do_overlay=1;
end

%if length(size(im))>2, 
%    disp('  more than 2 im-dim detected, using the first only');
%    im=im(:,:,1); 
%end;

if isempty(imaxis), imaxis=[1 size(im,2) 1 size(im,1)]; end;
if isempty(inv_flag), inv_flag=0; end;
if inv_flag, max_val=max(max(im))+1; end;

dxy=parms(2);
rang=[-parms(3):3:parms(3)];
ny=parms(1);
pord=parms(4);

cnt=1;
found_all=0;
if exist('tmp_manyRadROIs.mat','file'),
  usetmp=input('  tmp File found, use it (1=Yes, 0=No)?  ');
  if usetmp==1,
    load tmp_manyRadROIs cnt ROIs yf yout
  end;
end;

clf, myfig=gcf;
figure, clf, myfig2=gcf;

while(~found_all),
  clear tmpyy rad3b pval
  if cnt>1,
    msk=sum(ROIs,3)>0;
  else,
    msk=zeros(size(im));
  end;
  good_loc=0;
  while(~good_loc)
    disp(sprintf('  select cross-section (two pixel locations)...'));
    figure(myfig)
    if do_overlay,
      for mm=1:2, for nn=1:length(imov),
        show(imov{nn}), axis(imaxis),
        drawnow, pause(0.2), end
        show(im_super(im,msk,0.3)), axis(imaxis),
        drawnow
        pause(0.2);
      end
    else,
      show(im_super(im,msk,0.3)), axis(imaxis),
      drawnow
    end
    p1=round(ginput(2));
    msk=pixtoim([p1(:,2) p1(:,1)],size(im));
    show(im_super(im,msk,0.3)), axis(imaxis);
    drawnow,
    good_loc=input('  location ok? [1=yes, 0=no]: ');
  end;
  aloc(cnt,:)=mean(p1);
  dloc(cnt,:)=diff(p1);
  dd(cnt)=sqrt(sum(dloc(cnt,:).^2));
  dang(cnt)=atan(dloc(cnt,2)/dloc(cnt,1))*(180/pi);
  rw=[ny ceil(dd(cnt))];
  [tmp1,tmpmsk1]=getRectImGrid(im,rw,dxy,[aloc(cnt,2) aloc(cnt,1)],dang(cnt));
  yy{cnt}=mean(tmp1,2)';
  if inv_flag, yy{cnt}=max_val-yy{cnt}; end;
  show(im_super(im,tmpmsk1,0.3)), axis(imaxis),
  drawnow,
  if optangle_flag,
    disp(sprintf('  optimizing angle...'));
    for mm=1:length(rang),
      [tmpy,tmpymsk]=getRectImGrid(im,rw,dxy,[aloc(cnt,2) aloc(cnt,1)],dang(cnt)+rang(mm));
      tmpyy(mm,:)=mean(tmpy,2)';
      if inv_flag, tmpyy(mm,:)=max_val-tmpyy(mm,:); end;
      rad3b(mm,:)=calcRadius3b(tmpyy(mm,:));
    end; 
    pfit=polyfit(dang(cnt)+rang,rad3b(:,1)',pord);
    pval=polyval(pfit,dang(cnt)+rang);
    if optangle_flag==2,
      tmpri=find(rad3b(:,1)==max(rad3b(:,1)));
      tmppi=find(pval==max(pval));
    else,
      tmpri=find(rad3b(:,1)==min(rad3b(:,1)));
      tmppi=find(pval==min(pval));
    end;
    figure(myfig2)
    plot(dang(cnt)+rang,[rad3b(:,1) pval(:)])
    xlabel('angle'), ylabel('radius'),
    if (abs(tmpri-tmppi)>6),
      dang1(cnt)=dang(cnt)+rang(tmpri);
    else,
      dang1(cnt)=dang(cnt)+rang(tmppi);
    end;
    [tmpy,tmpymsk]=getRectImGrid(im,rw,dxy,[aloc(cnt,2) aloc(cnt,1)],dang1(cnt));
    figure(myfig)
    show(im_super(im,tmpymsk,0.3)), axis(imaxis),
    drawnow,
    disp(sprintf('  loc# %d  ang0= %.1f  ang= %.1f  (%d,%d)',cnt,dang(cnt),dang1(cnt),tmpri,tmppi));
    good_loc=input('  ROI ok? [1=yes, 0=no, 9=yes+exit, -1=change_width]: ');
    if (good_loc>0),
      yf{cnt}=mean(tmpy,2)';
      ROIs(:,:,cnt)=tmpymsk; 
      yout(cnt).rw=[ny ceil(dd(cnt))];
      yout(cnt).dxy=dxy;
      yout(cnt).aloc=[aloc(cnt,2) aloc(cnt,1)];
      yout(cnt).ang=dang1(cnt);
      yout(cnt).yp=yf{cnt};
      yout(cnt).mask=tmpymsk;
      cnt=cnt+1;
      save tmp_manyRadROIs cnt ROIs yf yout
    end;
    if (good_loc)==9,
      found_all=1;
    end;
    if (good_loc)==-1,
      ny=input(sprintf('    modify width (%d) to: ',ny));
    end;
  else,
    figure(myfig2), clf, plot(yy{cnt}),
    good_loc=input('  ROI ok? [1=yes, 0=no, 9=yes+exit, -1=change_width]: ');
    if (good_loc>0),
      yf{cnt}=mean(tmp1,2)';
      ROIs(:,:,cnt)=tmpmsk1;
      yout(cnt).rw=[ny ceil(dd(cnt))];
      yout(cnt).dxy=dxy;
      yout(cnt).aloc=[aloc(cnt,2) aloc(cnt,1)];
      yout(cnt).ang=dang(cnt);
      yout(cnt).mask=tmpmsk1;
      yout(cnt).yp=yf{cnt};
      cnt=cnt+1;
      save tmp_manyRadROIs cnt ROIs yf yout
    end;
    if (good_loc)==9,
      found_all=1;
    end;
    if (good_loc)==-1,
      ny=input(sprintf('    modify width (%d) to: ',ny));
    end;
  end;
end;

sIm=zeros(size(im));
for mm=1:size(ROIs,3),
  sIm(find(ROIs(:,:,mm)))=mm;
end;

if nargout==1,
  sIm_orig=sIm;
  clear sIm
  sIm=yout;
end;
  
if exist('tmp_manyRadROIs.mat','file'),
  if isunix,
    unix('rm tmp_manyRadROIs.mat');
  else,
    dos('delete tmp_manyRadROIs.mat');
  end
end;

