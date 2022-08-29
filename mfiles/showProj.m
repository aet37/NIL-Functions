function f=showProj(stk,type,filtparms,scaleparms,wlev,fig_flag)
% Usage ... f=showProj(stk,type,filt,scale,wlev)
%
% filt=[medfilt_wid gauss_smooth_wid z-adj-factor]
% scale=[x y z] in pixels

if ~exist('type','var'), type=[]; end;
if ~exist('filtparms','var'), filtparms=[]; end;
if ~exist('scaleparms','var'), scaleparms=[]; end;
if ~exist('wlev','var'), wlev=[]; end;
if ~exist('fig_flag','var'), fig_flag=[]; end;

if isempty(type), type='max'; end;

stk=squeeze(stk);
stkdim=size(stk);
if length(stkdim)>3, 
  disp(['  warning, stk dim > 3 ...']); 
  if stkdim(3)>3,
    disp(['  warning, #ch > 3, keeping last 3 ch']);
    stk=stk(:,:,end-2:end,:);
    stkdim=size(stk);
  end;
end;

if isempty(filtparms), filtparms=[0 0 0]; end;
if length(filtparms)==1, filtparms(2:3)=0; end;
if length(filtparms)==2, filtparms(3)=0; end;
if sum(filtparms(1:3))>0,
  tmprng=mean(mean(stk(:,:,1)))/mean(mean(stk(:,:,end)));
  if length(filtparms)==4, tmprng=filtparms(4); end;
  tmpaf=exp(filtparms(3)*[0:size(stk,3)-1]/size(stk,3))-1; 
  tmpaf=(tmpaf/max(tmpaf))*(tmprng-1)+1; 
  for mm=1:size(stk,3),
    if filtparms(1)>10*eps, stk(:,:,mm)=medfilt2(stk(:,:,mm),[1 1]*filtparms(2)); end;
    if filtparms(2)>10*eps, stk(:,:,mm)=im_smooth(stk(:,:,mm),filtparms(1)); end;
    %if filtparms(3)>10*eps, tmpaf(mm)=exp(filtparms(3)*(mm-1)/size(stk,3)); stk(:,:,mm)=tmpaf(mm)*stk(:,:,mm); end;
    if filtparms(3)>10*eps, stk(:,:,mm)=tmpaf(mm)*stk(:,:,mm); end;
  end;
  disp(sprintf('  sw=%.2f, mf=%d, af=[%.3f %.3f]',filtparms(1),filtparms(2),filtparms(3),tmpaf(end)));
  %figure, plot(tmpaf), pause, close,
end;

if (strcmp(type,'mean')|strcmp(type,'avg')),
  proj_12=mean(stk,length(stkdim));
  proj_13=squeeze(mean(stk,2));
  proj_23=squeeze(mean(stk,1));
else,
  %disp(sprintf('proj_12=%s(stk,[],length(stkdim));',type));
  eval(sprintf('proj_12=%s(stk,[],length(stkdim));',type));
  eval(sprintf('proj_13=squeeze(%s(stk,[],2));',type));
  eval(sprintf('proj_23=squeeze(%s(stk,[],1));',type));
end;

if length(stkdim)>3,
  proj_13=permute(proj_13,[1 3 2]);
  proj_23=permute(proj_23,[3 1 2]);
else,
  proj_23=proj_23';
end;

if ~isempty(scaleparms),
  [ii1,ii2]=meshgrid([1:size(proj_12,1)],[1:size(proj_12,2)]);
  [ii1new,ii2new]=meshgrid([1:scaleparms(1):size(proj_12,1)],[1:scaleparms(2):size(proj_12,2)]);
  for nn=1:size(proj_12,3),
    proj_12new(:,:,nn)=interp2(ii1,ii2,proj_12(:,:,nn)',ii1new,ii2new)';
  end;
  
  [ii1,ii2]=meshgrid([1:size(proj_13,1)],[1:size(proj_13,2)]);
  [ii1new,ii2new]=meshgrid([1:scaleparms(1):size(proj_13,1)],[1:scaleparms(3):size(proj_13,2)]);
  for nn=1:size(proj_12,3),
    proj_13new(:,:,nn)=interp2(ii1,ii2,proj_13(:,:,nn)',ii1new,ii2new)';
  end;
  
  [ii1,ii2]=meshgrid([1:size(proj_23,1)],[1:size(proj_23,2)]);
  [ii1new,ii2new]=meshgrid([1:scaleparms(3):size(proj_23,1)],[1:scaleparms(2):size(proj_23,2)]);
  for nn=1:size(proj_12,3),
    proj_23new(:,:,nn)=interp2(ii1,ii2,proj_23(:,:,nn)',ii1new,ii2new)';
  end;
  
  proj_12orig=proj_12;
  proj_12=proj_12new;
  proj_13orig=proj_13;
  proj_13=proj_13new;
  proj_23orig=proj_23;
  proj_23=proj_23new;
end;

if ~isempty(wlev)
  if length(wlev)==1, 
    minmax=mean(stk(:))+[-1 1]*wlev(1)*std(stk(:));
    if minmax(1)<min(stk(:)), minmax(1)=min(stk(:)); end;
    if minmax(2)>max(stk(:)), minmax(1)=max(stk(:)); end;
  else,
    minmax=wlev;
  end;
else,
  minmax=[min(stk(:)) max(stk(:))];
end;

if isempty(fig_flag),
  fig_flag=0;
end;

if fig_flag==0, 
  subplot(221),
  show(proj_12,minmax)
  subplot(222)
  show(proj_13,minmax)
  subplot(223)
  show(proj_23,minmax)
else,
  newfig=[proj_12 zeros(size(proj_12,1),20) proj_13];
  newfig(end+[1:20],:)=0;
  newfig=[newfig; proj_23' zeros(size(proj_23,2), 20+size(proj_13,2))];
  imagesc(newfig,minmax)
  colormap(gray(256)),
  axis('image'), axis('off'),
end

if nargout>0,
  if fig_flag==0,
    f.proj_12=proj_12;
    f.proj_13=proj_13;
    f.proj_23=proj_23;
    f.minmax=minmax;
  else,
    f.proj_12=proj_12;
    f.proj_13=proj_13;
    f.proj_23=proj_23;
    f.minmax=minmax;
    f.proj=newfig;
  end;
end;
