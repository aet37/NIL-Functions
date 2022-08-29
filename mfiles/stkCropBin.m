function [y,ii]=stkCropBin(stk,cropii,nbin)
% Usage ... [y,ii]=stkCropBin(stk,cropii,nbin)
%
% Ex. stk=stkCropBin(stk,'select',[]);

if nargin<3, nbin=[]; end;
if nargin<2, cropii=[]; end;

do_bin=1;
if isempty(nbin), do_bin=0; end;

do_select=0;
if isempty(cropii), do_select=1; end;
if isstr(cropii), do_select=1; end;

if do_select,
  tmpim=mean(stk,3);
  tmpfound=0;
  while(~tmpfound),
    figure(1), clf,
    show(tmpim), drawnow,
    disp('  select two locations...');
    tmploc=round(ginput(2));
    cropii=[sort(tmploc(1,2) tmploc(2,2)) sort(tmploc(1,1) tmploc(2,1))];
    if cropii(1)<1, cropii(1)=1; end;
    if cropii(3)<1, cropii(3)=1; end;
    if cropii(2)>size(tmpim,1), cropii(2)=size(tmpim,1); end;
    if cropii(4)>size(tmpim,2), cropii(4)=size(tmpim,2); end;
    cropii(2)=cropii(2)-rem(cropii(2)-cropii(1)+1,2);
    cropii(4)=cropii(4)-rem(cropii(4)-cropii(3)+1,2);
    disp(sprintf('  locs= %d %d %d %d',cropii));
    tmpmask=zeros(size(tmpim));
    tmpmask(cropii(1):cropii(2),cropii(3):cropii(4))=1;
    show(im_super(tmpim,tmpmask,0.5)), drawnow,
    tmpin=input('  locations ok? [1=yes, 0=no]: ');
    if tmpin==1, tmpfound=1; else, cropii=[]; end;
  end;
end;

if ~isempty(cropii),
  do_revert=0;
  if do_revert, cropii=[cropii(3:4) cropii(1:2)]; end;
  stk=stk(cropii(1):cropii(2),cropii(3):cropii(4),:);
else,
  disp('  warning: crop not done');
end;

if do_bin,
  y=volbin(stk,nbin);
else,
  y=stk;
end;

