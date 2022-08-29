function [y,wl]=volwlevel(vol,wl,norm,wltype)
% Usage ... [y,wl]=volwlevel(vol,wl,norm,type)
%
% Volume window level similar to imwlevel
% wl can be [min max] or [min max; per ch]
% or 'imminmax' or 'chminmax'

if nargin<4, wltype=[]; end;
if nargin<3, norm=[]; end;
if nargin<2, wl=[]; end;

if isempty(norm), norm=0; end;

vol=squeeze(vol);
vdim=size(vol);

% some easy cases first
if isempty(wl), 
  wl=[min(vol(:)) max(vol(:))];
  disp(['  vol min/max [',num2str(wl),']']);
  wl_type=0;
  y=vol;
  y(find(y<wl(1)))=wl(1);
  y(find(y>wl(2)))=wl(2);
  if norm, y=(y-wl(1))/(wl(2)-wl(1)); end;
  return,
end;

if length(wl(:))==2,
  disp(['  vol min/max ']);
  wl_type=0;
  y=vol;
  y(find(y<wl(1)))=wl(1);
  y(find(y>wl(2)))=wl(2);
  if norm, y=(y-wl(1))/(wl(2)-wl(1)); end;
  return,
end

if (size(wl,1)==vdim(3))&(size(wl,2)==2),
  wl_type=10;
  disp('  ch min/max');
  y=vol;
  for mm=1:vdim(3),
    tmpstk=y(:,:,mm,:);
    tmpwl=wl(mm,:);
    tmpstk(find(tmpstk<tmpwl(1)))=tmpwl(1);
    tmpstk(find(tmpstk>tmpwl(2)))=tmpwl(2);
    if norm, tmpstk=(tmpstk-tmpwl(1))/(tmpwl(2)-tmpwl(1)); end;
    y(:,:,mm,:)=tmpstk;
    clear tmpstk
  end;
  return,
end

% more cases
if ischar(wl),
  if strcmp(wl,'imminmax'),
    wl=[];
    wl_type=1;
    disp('  image min/max'); 
  elseif strcmp(wl,'immax'),
    wl=[];
    wl_type=2;
    disp('  vol min/image max'); 
  elseif strcmp('chminmax'),
    wl_type=10;
    disp('  ch min/max');
    y=vol;
    for mm=1:size(y,3),
      tmpstk=y(:,:,mm,:);
      tmpwl=[min(tmpstk(:)) max(tmpstk(:))];
      wl(mm,:)=tmpwl;
      tmpstk(find(tmpstk<tmpwl(1)))=tmpwl(1);
      tmpstk(find(tmpstk>tmpwl(2)))=tmpwl(2);
      if norm, tmpstk=(tmpstk-tmpwl(1))/(tmpwl(2)-tmpwl(1)); end;
      y(:,:,mm,:)=tmpstk;
    end;
    return,
  else,
    wl_type=0;
    disp('  vol min/max');
    wl=[min(vol(:)) max(vol(:))];
    y=vol;
    wl_type=0;
    y(find(y<wl(1)))=wl(1);
    y(find(y>wl(2)))=wl(2);
    if norm, y=(y-wl(1))/(wl(2)-wl(1)); end;
    return,
  end;
end;

if ~isempty(wltype), wl_type=wltype; end;

if isempty(wl),
  if length(vdim)==3,
    for mm=1:vdim(3),
      tmpim=vol(:,:,mm);
      if wl_type==1,
        wl(mm,:)=[min(tmpim(:)) max(tmpim(:))];
      elseif wl_type==2,
        wl(mm,:)=[min(vol(:)) max(tmpim(:))];
      end;
    end;
  elseif length(vdim)==4,
    for mm=1:vdim(3), tmpvol=squeeze(vol(:,:,mm,:)); volmin(mm)=min(tmpvol(:)); clear tmpvol ; end;
    for mm=1:vdim(3), for nn=1:vdim(4),
      tmpim=vol(:,:,mm,nn);
      if wl_type==1,
        wl(mm,nn,:)=[min(tmpim(:)) max(tmpim(:))];
      elseif wl_type==2,
        wl(mm,nn,:)=[volmin(mm) max(tmpim(:))];
      end;
    end; end;
  end;
  disp(sprintf('  average min/max=[%.2f %.2f]',mean(wl(:,1)),mean(wl(:,2))));
else,
  if length(wl)==2,
    wl_type=0;
    tmpwl=wl; clear wl
    if length(vdim)==4,
      for mm=1:vdim(4), for nn=1:vdim(3), wl(nn,mm,:)=tmpwl; end; end;
    else,
      for mm=1:vdim(3), wl(mm,:)=tmpwl; end;
    end;
  end;
end;

y=vol;

if length(vdim)==4,
  for mm=1:vdim(4), for nn=1:vdim(3),
    y(:,:,nn,mm)=imwlevel(squeeze(y(:,:,nn,mm)),squeeze(wl(nn,mm,:)),norm);
  end; end;
else,
  for mm=1:vdim(3),
    y(:,:,mm)=imwlevel(squeeze(y(:,:,mm)),wl(mm,:),norm);
  end;
end;
