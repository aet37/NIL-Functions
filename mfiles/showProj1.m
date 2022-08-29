function y=showStack(stk,ax,dd,nn,ptype)
% Usage ... showStack(stk,axis,dd,nn,ptype)

if ~exist('ptype','var'), ptype='max'; end;
if ~exist('dd','var'), dd=3; end;
if ~exist('nn','var'), nn=round(0.1*size(stk,3)); end;
if ~exist('ax','var'), ax=[]; end;

S.fh=figure('keypressfcn',@fh_kpfcn);
%S.tx=uicontrol('style','text');
S.stk=stk;
S.sdim=size(stk);
S.mm=1;
S.fp=[];
S.pdim=dd;
S.ndim=nn;
S.pii=S.mm+[0:S.ndim-1];
S.ptype=ptype;

if exist('ax','var'),
  S.ax=ax; 
else,
  if dd==1, 
    S.ax=[1 S.sdim(2) 1 S.sdim(3)];
  elseif dd==2,
    S.ax=[1 S.sdim(1) 1 S.sdim(3)];
  else,
    S.ax=[1 S.sdim(1) 1 S.sdim(2)];
  end;
  disp(sprintf('  axis= %d %d',S.ax(1),S.ax(2)));
end;

S.pim=mypshow(S.stk,S.pdim,S.ptype,S.pii);
axis(S.ax), disp(sprintf('  %s: %d/%d',S.ptype,S.pii(1),S.pii(end))),
drawnow;
guidata(S.fh,S);
if nargout==1,
  y=S.pim;
end;

function []=fh_kpfcn(H,E)
% figure keypressfcn
S=guidata(H);
%set(S.tx,'string',E.Key);
tmpupdate=0;
tmpexit=0;
switch E.Key
    case 'rightarrow'
        S.mm=S.mm+1; tmpupdate=1;
    case 'downarrow'
        S.mm=S.mm+1; tmpupdate=1;
    case 'leftarrow'
        S.mm=S.mm-1; tmpupdate=1;
    case 'uparrow'
        S.mm=S.mm-1; tmpupdate=1;
    case '-'
        S.ndim=S.ndim-1; tmpupdate=1;
    case '_'
        S.ndim=S.ndim-1; tmpupdate=1;
    case '='
        S.ndim=S.ndim+1; tmpupdate=1;
    case '+'
        S.ndim=S.ndim+1; tmpupdate=1;
    case 'n'
        tmpin=input('  enter #: ');
        S.ndim=tmpin; tmpupdate=1;
    case 't'
        tmpin=input('  enter type ','s');
        S.ptype=tmpin; tmpupdate=1;
    case 'q'
        tmpexit=1;
    case 'Q'
        tmpexit=1;
    case 'x'
        tmpexit=1;
    case 'X'
        tmpexit=1;
end;
S.pii=S.mm+[0:S.ndim-1];
S.pii=S.pii(find((S.pii>=1)&(S.pii<=S.sdim(S.pdim))));
if tmpexit,
  close(H);
  if ~isempty(S.fp), close(S.fp); end;
end;
if tmpupdate,
  if S.mm<1,
    S.mm=1;
  elseif S.mm>S.sdim(3),
    S.mm=S.sdim(3);
  else,
    S.pim=mypshow(S.stk,S.pdim,S.ptype,S.pii); 
    axis(S.ax), 
    disp(sprintf('  %s: %d/%d',S.ptype,S.pii(1),S.pii(end)));
    drawnow;
  end;
  guidata(H,S);
  uiresume(H);
end;
y=S.pim;

function a=mypshow(stk,pdim,ptype,pii,level)
if pdim==1,
  stk=stk(pii,:,:);
elseif pdim==2,
  stk=stk(:,pii,:);
else,
  stk=stk(:,:,pii);
end;
if strcmp(ptype,'mean')|strcmp(ptype,'avg'),
  a=squeeze(mean(stk,pdim));
elseif strcmp(ptype,'max'),
  a=squeeze(max(stk,[],pdim));
elseif strcmp(ptype,'min'),
  a=squeeze(min(stk,[],pdim));
elseif strcmp(ptype,'std'),
  a=squeeze(std(stk,[],pdim));
elseif strcmp(ptype,'var'),
  a=squeeze(var(stk,[],pdim));
elseif strcmp(ptype,'median'),
  a=squeeze(median(stk,pdim));
else,
  a=squeeze(mean(stk,pdim));
  disp('  showing mean');
end;
if nargin==4,
  level=[min(a(:)) max(a(:))];
end;
imagesc(a,level);
title(sprintf('min/max= %f/%f',level(1),level(2)));
xlabel(sprintf('%s(%d): %d %d',ptype,pdim,pii(1),pii(end)));
axis('image');
grid('on');
colormap(gray);
return;

