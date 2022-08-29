function [y,ys]=pmGCAMPmask1(im,parms)
% Usage ... y=pmGCAMPmask1(im)

%floor(sqrt(prod(size(im))/10)),

if exist('parms','var'),
  fp=parms;
else,
  fp=floor(sqrt(prod(size(im))/4));
end;

disp('  select brain mask...');
maskB=selectMask(im);

disp('  select vessel mask...');
maskV=selectMask(im);

tmpim1=homocorOIS(im,fp);
tmpim1=tmpim1/mean(tmpim1(find(maskB)))-1;
tmpii=find(maskB&maskV);
tmpval=[mean(tmpim1(tmpii)) std(tmpim1(tmpii))],

tmpim1=tmpim1-tmpval(1);
maskM=im_thr2(tmpim1.*maskB,2.5*tmpval(2),4);

tmpok=0;
while(~tmpok),
  clf, show(maskM>0), drawnow,
  tmpin=input('  gcamp mask [e=edit, n=new, accept=enter]: ','s');
  if isempty(tmpin),
    tmpok=1;
  else,
    if strcmp(tmpin,'e'),
      maskM=editMask(maskM,tmpim1,'roi');
    elseif strcmp(tmpin,'n'),
      maskM=selectMask(tmpim1);
    end;
  end;
end;

ys.refim=tmpim1;
ys.maskB=maskB;
ys.maskV=maskV;
ys.mask=maskM;

y=maskM;
y=ys;

