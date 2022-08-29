function plotmany(y,nmax,wl,nrowcol)
% Usage ... plotmany(y,nmax,wl,nrowcol)

pmax=100;

if ~exist('nmax'), nmax=[]; end; 
if ~exist('wl'), wl=[]; end;
if ~exist('nrowcol'), nrowcol=[]; end;

if iscell(y), do_cell=1; else, do_cell=0; end;
if isempty(nmax), if do_cell, nmax=length(y); else, nmax=size(y,3); end; end;

if length(wl)==0, 
  redowl=0;
else,
  redowl=1;
end;

do_more=0;
if do_cell, ydim3=length(y); else, ydim3=size(y,3); end;
if ydim3>nmax,
  do_more=1;
  nmore=ceil(ydim3/nmax)-1;
end;
if isempty(nrowcol),
  nrows=ceil(sqrt(nmax));
  ncols=ceil(nmax/nrows);
else,
  if length(nrowcol)==1,
      nrows=nrowcol(1);
      ncols=ceil(nmax/nrows);
  else,
      nrows=nrowcol(1);
      ncols=nrowcol(2);
  end
end

if nmax>pmax,
  disp(sprintf('  max# plots exceeded (%d/%d), aborting...',nmax,pmax));
  return,
end;

for mm=1:nmax,
  crow=rem(mm,ncols);
  ccol=floor(mm/ncols)+1;
  subplot(nrows,ncols,mm),
  if do_cell, tmpim=y{mm}; else, tmpim=y(:,:,mm); end;
  if length(size(tmpim))==3, do_color=1; else, do_color=0; end;
  if do_color,
      if redowl==1, show(tmpim,wl), else, show(tmpim), end;
  else
      if redowl==1, imagesc(tmpim,wl), else, imagesc(tmpim), end; axis image, colormap gray, title(sprintf('%f/%f',min(tmpim(:)),max(tmpim(:)))),
  end
  xlabel(num2str(mm)),
end;

if do_more,
  cnt=mm;
  for nn=1:nmore,
    figure,
    for oo=1:nmax,
      cnt=cnt+1;
      if cnt<=size(y_vec,2),
        subplot(nrows,ncols,oo),
        if do_cell, tmpim=y{mm}; else, tmpim=y(:,:,mm); end;
        if do_color,
            if redowl, show(tmpim,wl), else, show(tmpim); end; 
        else
            if redowl, imagesc(tmpim,wl), else, imagesc(tmpim); end; axis image, colormap gray, title(sprintf('%f/%f',min(tmpim(:)),max(tmpim(:)))),
        end
        xlabel(num2str(cnt)),
      end;
    end;
  end;
end;

