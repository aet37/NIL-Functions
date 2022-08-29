function [y,yorig,kim_new]=mykreorder1(kim1,kim_ref,transp)
% Usage ... [y,yorig,kim_new]=mykreorder1(kim1,kim_ref,transp_ref)
%
% GUI to reorder kindeces in kim1 to match kim_ref
% if no reference is provided, kim1 is ordered

if ~exist('transp','var'),
  transp=0;
end;

if exist('kim_ref','var'), 
  if prod(size(kim_ref))==length(kim_ref),
    do_ref=2;
  else,
    do_ref=1; 
  end;
else,
  do_ref=0;
end;

if transp==1,
  disp('  transposing 1 ref...');
  kim_ref=kim_ref';
elseif transp==2,
  disp('  transposing 2 ref...');
  kim_ref=fliplr(kim_ref);
elseif transp==3,
  disp('  transposing 3 ref...');
  kim_ref=flipud(kim_ref);
elseif transp==4,
  disp('  transposing 4 ref...');
  kim_ref=fliplr(flipud(kim_ref));
end;


nk=max(kim1(:));
kim_new=zeros(size(kim1));

if do_ref==2,
  y=zeros(size(kim1));
  for mm=1:length(kim_ref),
    y(find(kim1==kim_ref(mm)))=mm;
  end;
  tmpy=kim_ref;
  tmporig=[];
  yorig=[];
elseif do_ref==1,
  tmpcnt=0;
  tmpfound=0;
  figure(1), clf,
  while(~tmpfound),
    figure(1), 
    subplot(221), imagesc(kim_ref), axis('image'), colormap(jet), colorbar, xlabel('Reference Image'),
    subplot(222), imagesc(kim1), axis('image'), colormap(jet), colorbar, xlabel('Original Image'),
    subplot(223), imagesc(kim_new), axis('image'), colormap(jet), colorbar, xlabel('New Image'),
    disp(sprintf('  click on area in Reference...'));
    tmploc=round(ginput(1));
    tmpok=0;
    if (tmploc(2)>0)&(tmploc(1)>0)&(tmploc(2)<=size(kim_ref,1))&(tmploc(1)<=size(kim_ref,2)),
      tmpok=1;
    else,
      tmpfound=1;
    end;
    if tmpok,
      tmplabel=kim_ref(tmploc(2),tmploc(1));
      disp(sprintf('    [%d,%d] id=%d',tmploc(1),tmploc(2),tmplabel));
      disp(sprintf('  click on area in Original to assign this id...'));
      tmploc=round(ginput(1));
      if (tmploc(2)>0)&(tmploc(1)>0)&(tmploc(2)<=size(kim1,1))&(tmploc(1)<=size(kim1,2)),
        tmporiglabel=kim1(tmploc(2),tmploc(1));
        kim_new(find(kim1==tmporiglabel))=tmplabel;
        disp(sprintf('  [%d,%d] id=%d NOW %d',tmploc(1),tmploc(2),tmporiglabel,tmplabel));
        tmpcnt=tmpcnt+1;
        tmporig(tmpcnt)=tmporiglabel;
        tmpy(tmpcnt)=tmplabel;
        %subplot(224),
        %imagesc(kim_new), axis('image'), colorbar,
      end;   
    end;
  end;

  tmpcnt=0;
  for mm=1:max(kim1(:)),
    tmpfind=find(tmporig==mm);
    if length(tmpfind)>=1,
      tmpcnt=tmpcnt+1;
      tmporig2(tmpcnt)=tmporig(tmpfind(end));
      tmpy2(tmpcnt)=tmpy(tmpfind(end));
    end;
  end;
  [tmpa,tmpb]=sort(tmpy2);
  tmpy2=tmpa;
  tmporig2=tmporig2(tmpb);
  y=tmporig2;
  yorig=tmpy2;
  
  subplot(224)
  tmpkim=zeros(size(kim1));
  for mm=1:length(y),
    tmpkim(find(kim1==y(mm)))=mm;
  end;
  imagesc(tmpkim), axis('image'), colormap(jet), colorbar,
  xlabel('Final'),
  
else,
  close all
  figure(2)
  imagesc(kim_new), axis('image'), colorbar,
  tmpcnt=0;
  tmpfound=0;
  while(~tmpfound),
    figure(1)
    imagesc(kim1), axis('image'), colorbar, xlabel('Original Image'),
    disp(sprintf('  click on area in fig1...'));
    tmploc=round(ginput(1));
    if (tmploc(2)>0)&(tmploc(1)>0)&(tmploc(2)<=size(kim1,1))&(tmploc(1)<=size(kim1,2)),
      tmplabel=kim1(tmploc(2),tmploc(1));
      disp(sprintf('    [%d,%d] id=%d',tmploc(1),tmploc(2),tmplabel));
      tmpin=input('  set id [-1: exit]= ');
      if (tmpin<0),
        tmpfound=1;
      else,
        tmpcnt=tmpcnt+1;
        kim_new(find(kim1==tmplabel))=tmpin;
        tmporig(tmpcnt)=tmplabel;
        tmpy(tmpcnt)=tmpin;
        figure(2),
        imagesc(kim_new), axis('image'), colorbar,
        figure(1), 
      end;
    else,
      tmpfound=1;
    end; 
  end;

  tmpcnt=0;
  for mm=1:length(tmporig(:)),
    tmpcnt=tmpcnt+1;
    if tmpcnt<=max(tmporig(:)),
      tmpfind=find(tmporig==tmpcnt);
      if length(tmpfind)>=1,
        tmporig2(tmpcnt)=tmporig(tmpfind(end));
        tmpy2(tmpcnt)=tmpy(tmpfind(end));
      end;
    end;
  end;
  %y=tmpy2;
  %yorig=tmporig2;
  y=tmporig;
  yorig=tmpy;

end;

if nargout==0,
  [tmpy(:) tmporig(:)],
  [y(:) yorig(:)],
end;

