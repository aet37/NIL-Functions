function showPrairie(x,o1,o2,o3,o4,o5)
% Usage ... showPrairie(x)
%
% Options: 'filter', 'ortho', 'wlevel'

ss=size(x);

filter_flag=0;
ortho_flag=0;
level_flag=0;
if (nargin>1),
  disp('  evaluating input flags...');
  for mm=1:nargin-1,
    eval(sprintf('if strcmp(o%d,''filter''), filter_flag=1; end;',mm));
    eval(sprintf('if strcmp(o%d,''ortho''), ortho_flag=1; end;',mm));
    eval(sprintf('if strcmp(o%d,''wlevel''), level_flag=1; wl=o%d; end;',mm,mm+1));
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
    tmpim1(:,:,mm)=squeeze(mean(x(:,:,mm,:),4));
    tmpim2(:,:,mm)=squeeze(mean(x(:,:,mm,:),1));
    tmpim3(:,:,mm)=squeeze(mean(x(:,:,mm,:),2))';
  end;
  if nch==1,
    tmpim1(:,:,2)=tmpim1; tmpim1(:,:,3)=tmpim1;
    tmpim2(:,:,2)=tmpim2; tmpim2(:,:,3)=tmpim2;
    tmpim3(:,:,2)=tmpim3; tmpim3(:,:,3)=tmpim3;
  elseif nch==2,
    tmpim1(:,:,3)=0; tmpim2(:,:,3)=0; tmpim3(:,:,3)=0;
  end;

  if (level_flag==0),
    wl=[min(min(tmpim1)) max(max(tmpim1))];
  else,
    disp(sprintf('  wlevel=[%.2f %.2f]',wl(1),wl(2)));
  end;

  clf,
  if (ortho_flag),
    subplot(221)
    image(imwlevel(tmpim1,[wl(1) wl(2)])), axis('image'),
    title(sprintf('[%.2f, %.2f]',wl(1),wl(2)));
    subplot(222)
    image(imwlevel(tmpim2,[wl(1) wl(2)])),
    subplot(223)
    image(imwlevel(tmpim3,[wl(1) wl(2)])),
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

