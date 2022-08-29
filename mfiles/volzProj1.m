function volzp=volzProj1(vol,np,nskp,ptype)
% Usage ... volzp=volzProj1(vol,np,nskp,ptype)
%
% Volume sliding projection
% np is the number of planes
% nskp is the number of planes to skip
% ptype is the projection type (0=mean, 1=max, 2=min, 3=std)
%
% Ex. volzProj1(data,10,10,1)


do_fig=0;
if nargout==0, do_fig=1; end;

if ~exist('nskp','var'), nskp=ceil(np/2); end;
if isempty(nskp), nskp=1; end;
if nskp<1, nskp=1; end;

volsz=size(vol);

if nargin<4, ptype=[]; end;
if isempty(ptype), ptype=1; end;
if ischar(ptype),
  if strcmp(ptype,'max'), ptype=1; 
  elseif strcmp(ptype,'min'), ptype=2;
  elseif strcmp(ptype,'std'), ptype=3;
  else, ptype=0;
  end;
end

ntotal=volsz(end);
nproj=floor(ntotal/nskp);

if length(volsz)==4,
  for mm=1:nproj+1,
    tmpii=[1:np]+(mm-1)*nskp;
    tmpii=tmpii(find(tmpii<=volsz(end)));
    if ~isempty(tmpii),
    if do_fig, disp(sprintf('  %d: %d to %d (%d), total= %d',mm,tmpii(1),tmpii(end),length(tmpii),volsz(end))); end;
    tmpzp=vol(:,:,:,tmpii);
    if ptype==1, 
        tmpp=max(tmpzp,[],4);
    elseif ptype==2,
        tmpp=min(tmpzp,[],4);
    elseif ptype==3,
        tmpp=std(tmpzp,[],4);
    else,
        tmpp=mean(tmpzp,4);
    end
    volzp(:,:,:,mm)=tmpp;
    clear tmpzp tmpp
    end
  end

else,
  for mm=1:nproj+1,
    tmpii=[1:np]+(mm-1)*nskp;
    tmpii=tmpii(find(tmpii<=volsz(end)));
    if ~isempty(tmpii),
    if do_fig, disp(sprintf('  %d: %d to %d (%d), total= %d',mm,tmpii(1),tmpii(end),length(tmpii),volsz(end))); end;
    tmpzp=vol(:,:,tmpii);
    if ptype==1, 
        tmpp=max(tmpzp,[],3);
    elseif ptype==2,
        tmpp=min(tmpzp,[],3);
    elseif ptype==3,
        tmpp=std(tmpzp,[],3);
    else,
        tmpp=mean(tmpzp,3);
    end
    volzp(:,:,mm)=tmpp;
    clear tmpzp tmpp
    end
  end
end

if do_fig,
  showStack(volzp)
  clear volzp
end


  