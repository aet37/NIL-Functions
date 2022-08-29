function [y,ys]=pmMethoxyMask1(im,parm,redo_mask)
% Usage ... y=pmMethoxyMask1(im)
%
% parm = [flatn thrf cthr_min cthr_max]
% Note: im can be the input structure which would fill out the missing fields
% of output structure y 
%
% Ex. gapp11_mex(1)=pmMethoxyMask1(gapp11_mex(1),[32 2 10 2000]);

if nargin<3, redo_mask=0; end;

do_struct=0;
if isstruct(im),
  ys=im;
  im=ys.img;
  do_struct=1;
  clf, show(im), drawnow,
  tmpin=input('  adjust min/max? [0/enter=no, 1=yes]: ');
  if isempty(tmpin), tmpin=0; end;
  if tmpin,
    tmpminmax=[min(im(:)) max(im(:))];
    tmpminmax1=tmpminmax;
    tmpok=0;
    while(~tmpok),
        clf, show(im,tmpminmax), drawnow,
        tmpin2=input('  enter [min max] or enter to continue: ','s');
        if isempty(tmpin2),
          tmpok=1;
        else,
          eval(sprintf('tmpminmax=[%s];',tmpin2));
        end;      
    end
    im=imwlevel(im,tmpminmax,0);
  end;
end;

if exist('parm','var'),
  fm=parm(1);
  thrf=parm(2);
  cthr=parm(3:4);
else,
  fm=floor(sqrt(prod(size(im))/64));
  thrf=2;
  cthr=[4 1600];
end;

if redo_mask==0,
if do_struct, if isfield(ys,'mask'), if ~isempty(ys.mask),
  disp('  using structure maskB');
  maskB=ys.mask.maskB;
  maskM=ys.mask.mask;
end; end; end; end;

if ~exist('maskB','var'),
  disp('  select brain mask...');
  maskB=selectMask(im);
end;

tmpim1=homocorOIS(im,fm);
tmpim1=tmpim1/mean(tmpim1(find(maskB)))-1;
tmpim1a=tmpim1;

tmpok=0; do_update=1;
if exist('maskM','var'), if ~isempty(maskM),
  do_update=0;
end; end;
while(~tmpok),
  if do_update, maskM=im_thr2(tmpim1a.*maskB,thrf(1)*std(tmpim1(find(maskB))),cthr); end;
  clf, subplot(121), show(tmpim1), subplot(122), show(maskM>0), drawnow,
  tmpin=input(sprintf('  methoxy mask [txx=thrf(%.1f), e=edit, n=newB, r=reset, sX=smooth, lX=flat, f=flash, accept=enter]: ',thrf(1)),'s');
  if isempty(tmpin),
    tmpok=1;
  else,
    if strcmp(tmpin,'e'),
      maskM=editmask(maskM,tmpim1a.*maskB,'roi');
      do_update=0;
    elseif strcmp(tmpin,'n'),
      maskM=selectMask(tmpim1a.*maskB);
      do_update=0;
    elseif strcmp(tmpin(1),'r'),
      tmpim1a=tmpim1;
      do_update=1;
    elseif strcmp(tmpin(1),'t'),
      thrf=str2double(tmpin(2:end));
      disp(sprintf('  thrf= %.2f',thrf));
      do_update=1;
    elseif strcmp(tmpin(1),'s'),
      tmpim1a=im_smooth(tmpim1a,str2num(tmpin(2:end)));
      do_update=1;
    elseif strcmp(tmpin(1),'l'),
      tmpim1a=homocorOIS(tmpim1a,str2num(tmpin(2:end)));
      do_update=1;
    elseif strcmp(tmpin(1),'f'),
      do_update=0;
      subplot(122), for mm=1:2, im_overlay4(tmpim1a,maskM>0), drawnow, pause(0.4), show(maskM>0), drawnow, pause(0.4), end;
    end;
  end;
end;

if do_struct,
  ys.mask.refim=tmpim1a;
  ys.mask.maskB=maskB;
  ys.mask.mask=maskM;
  ys.maskSum=sum(maskM(:)>0);
  if isfield(ys,'maskRatio'), ys.maskRatio=sum(maskM(:))/sum(maskB(:)); end;
  if isfield(ys,'ageNum'), ys.ageNum=datenum(ys.imgDate)-datenum(ys.mouseDOB); end;
  
  y=ys;
  ys=maskM;
end;



