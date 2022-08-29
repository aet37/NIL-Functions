function f=showPrairie2(x,o1,o2,o3,o4,o5,o6,o7,o8)
% Usage ... showPrairie(x)
%
% Options: 'filter', 'ortho', 'wlevel', 'max', 'dim'

ss=size(x);

filter_flag=0;
ortho_flag=0;
level_flag=0;
max_flag=0;
pdim=[ss([1 2 4])];
dim_flag=0;
if (nargin>1),
  disp('  evaluating input flags...');
  for mm=1:nargin-1,
    eval(sprintf('if strcmp(o%d,''filter''), filter_flag=1; end;',mm));
    eval(sprintf('if strcmp(o%d,''ortho''), ortho_flag=1; end;',mm));
    eval(sprintf('if strcmp(o%d,''wlevel''), level_flag=1; wl=o%d; end;',mm,mm+1));
    eval(sprintf('if strcmp(o%d,''max''), max_flag=1; end;',mm));
    eval(sprintf('if strcmp(o%d,''dim''), dim_flag=1; pdim=o%d; end;',mm,mm+1));
  end;
end; 

if length(ss)==4,
  if filter_flag,
    disp('  filtering data...');
    for mm=1:ss(3), for nn=1:ss(4),
      x(:,:,mm,nn)=medfilt2(x(:,:,mm,nn),[3 3]);
      x(:,:,mm,nn)=real(im_smooth(x(:,:,mm,nn),1));
    end; end;
  end;
  if ss(3)>3, nch=3; else, nch=ss(3); end;
  for mm=1:nch,
    if max_flag,
      tmpim1(:,:,mm)=squeeze(max(x(:,:,mm,:),[],4));
      tmpim2(:,:,mm)=squeeze(max(x(:,:,mm,:),[],1))';
      tmpim3(:,:,mm)=squeeze(max(x(:,:,mm,:),[],2))';
    else,
      tmpim1(:,:,mm)=squeeze(mean(x(:,:,mm,:),4));
      tmpim2(:,:,mm)=squeeze(mean(x(:,:,mm,:),1))';
      tmpim3(:,:,mm)=squeeze(mean(x(:,:,mm,:),2))';
    end;        
  end;
  if nch==1,
    tmpim1(:,:,2)=tmpim1(:,:,1); tmpim1(:,:,3)=tmpim1(:,:,1);
    tmpim2(:,:,2)=tmpim2(:,:,1); tmpim2(:,:,3)=tmpim2(:,:,1);
    tmpim3(:,:,2)=tmpim3(:,:,1); tmpim3(:,:,3)=tmpim3(:,:,1);
  elseif nch==2,
    tmpim1(:,:,3)=0; tmpim2(:,:,3)=0; tmpim3(:,:,3)=0;
  end;

  if (dim_flag),
    xx=[1:ss(1)];
    yy=[1:ss(2)];
    zz=[1:ss(4)];
    xxi=[0:pdim(1)-1]*(ss(1)-1)/(pdim(1)-1)+1;
    yyi=[0:pdim(2)-1]*(ss(2)-1)/(pdim(2)-1)+1;
    zzi=[0:pdim(3)-1]*(ss(4)-1)/(pdim(3)-1)+1;
    [xxx,yyy]=meshgrid(xx,yy);
    [xxxi,yyyi]=meshgrid(xxi,yyi);
    for mm=1:size(tmpim1,3),
      tmpim1i(:,:,mm)=interp2(xxx,yyy,tmpim1(:,:,mm),xxxi,yyyi,'cubic');
    end;
    [xxx,zzz]=meshgrid(xx,zz);
    [xxxi,zzzi]=meshgrid(xxi,zzi);
    for mm=1:size(tmpim2,3),
      tmpim2i(:,:,mm)=interp2(xxx,zzz,tmpim2(:,:,mm),xxxi,zzzi,'cubic');
    end;
    [yyy,zzz]=meshgrid(yy,zz);
    [yyyi,zzzi]=meshgrid(yyi,zzi);
    for mm=1:size(tmpim3,3),
      tmpim3i(:,:,mm)=interp2(yyy,zzz,tmpim3(:,:,mm),yyyi,zzzi,'cubic');
    end;
    tmpim1o=tmpim1;
    tmpim2o=tmpim2;
    tmpim3o=tmpim3;
    clear tmpim1 tmpim2 tmpim3
    tmpim1=tmpim1i;
    tmpim2=tmpim2i;
    tmpim3=tmpim3i;
  end;
        
  if (level_flag==0),
    wl=[min(min(tmpim1)) max(max(tmpim1))];
  else,
    disp(sprintf('  wlevel=[%.2f %.2f]',wl(1),wl(2)));
  end;

  clf,
  if (ortho_flag),
    figure(1)
    subplot(221)
    %figure(1)
    image(imwlevel(tmpim1,[wl(1) wl(2)])), axis('image'),
    title(sprintf('[%.2f, %.2f]',wl(1),wl(2)));
    subplot(222)
    %figure(2)
    image(imwlevel(tmpim2,[wl(1) wl(2)])),
    subplot(223)
    %figure(3)
    image(imwlevel(tmpim3,[wl(1) wl(2)])),
    tmpgap=round(0.05*size(tmpim1,1));
    for mm=1:size(tmpim1,3),
      if mm==1,
        tmpim4(:,:,mm)=[tmpim1(:,:,mm);zeros(tmpgap,size(tmpim1,2));tmpim2(:,:,mm)];
        tmpim4ss=size(tmpim4);
      else,
        tmpim4(1:tmpim4ss(1),1:tmpim4ss(2),mm)=[tmpim1(:,:,mm);zeros(tmpgap,size(tmpim1,2));tmpim2(:,:,mm)];
      end;
      tmpim4([1:size(tmpim3,2)],[1:size(tmpim3,1)]+size(tmpim1,2)+tmpgap,mm)=flipud(tmpim3(:,:,mm)');
    end;
    figure(2)
    image(imwlevel(tmpim4,[wl(1) wl(2)])), axis('image'),
    title(sprintf('[%.2f, %.2f]',wl(1),wl(2)));    
  else,
    image(imwlevel(tmpim1,[wl(1) wl(2)])), axis('image'),
    title(sprintf('[%.2f, %.2f]',wl(1),wl(2)));
  end;
 
elseif length(ss)==3,

  if filter_flag,
    disp('  filtering data...');
    for mm=1:ss(3),
      x(:,:,mm)=medfilt2(x(:,:,mm),[3 3]);
      x(:,:,mm)=real(im_smooth(x(:,:,mm),1));
    end; 
  end;
  if ss(3)>3, nch=3; else, nch=ss(3); end;
  for mm=1:nch, tmpim(:,:,mm)=x(:,:,mm); end;
  if nch==1,
    tmpim(:,:,2)=tmpim(:,:,1); tmpim(:,:,3)=tmpim(:,:,1);
  elseif nch==2,
    tmpim(:,:,3)=0;
  end;
  if (level_flag==0),
    wl=[min(min(tmpim)) max(max(tmpim))];
  end;
  image(imwlevel(tmpim,[wl(1) wl(2)])), axis('image'),
  title(sprintf('[%.2f, %.2f]',wl(1),wl(2)));

else,

  disp('Nothing implemented at the moment for this dimmensionality');

end;

if nargout==1,
  f.im1=tmpim1;
  f.im2=tmpim2;
  f.im3=tmpim3;
end;

