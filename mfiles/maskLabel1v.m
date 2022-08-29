function [labelim,label,nV,iV]=maskLabel1(mask,tc,im,prev)
% Usage ... [labelim,label,nV,iV]=maskLabel1(mask,tc,im,prev)

clf,
if isstruct(mask),
  nroi=length(mask);
else,
  nroi=max(mask(:));
end;
labelim=zeros(size(im(:,:,1)));

% first label ROIs for each blood vessel

mm=1;
cnt1=0;
tmpfound=0;
if nargin>3, labelim=prev{1}; label=prev{2}; tmpfound=1; end;
if exist('tmp_masklabel1v.mat'),
  usetmp=input('  tmp File found, use it (1=Yes, 0=No)?  ');
  if usetmp==1,
    load tmp_masklabel1v
  end;
end;
while(~tmpfound),
  tmpgood=0;
  figure(2)
  plot(tc(:,mm)), axis('tight'), grid('on'), xlabel(num2str(mm)), drawnow,
  figure(1)
  if isstruct(mask),
    [tmp1,tmp2]=getRectImGrid(im,mask(mm));
    im_overlay4(im(:,:,1),tmp2), xlabel(num2str(mm)), drawnow,
  else,
  %for oo=1:2, for pp=1:size(im,3),
  %  show(im(:,:,pp)), title(''),  drawnow, pause(0.3),
    im_overlay4(im(:,:,1),mask==mm), xlabel(num2str(mm)), drawnow, 
    %pause(0.3),
  %end; end;
  end;
  tmpin=input('  label (#,reshow,back,new,same,ignore)= ','s');
  if strcmp(tmpin,'b'),
    mm=mm-1;
  elseif strcmp(tmpin,'r'),
    mm=mm;
  elseif strcmp(tmpin,'g'),
    mm=input('  goto# : ');
  elseif strcmp(tmpin,'n'),
    cnt1=cnt1+1;
    label(mm,:)=cnt1;
    disp(sprintf(' new label (%d)',cnt1));
    if isstruct(mask), 
      labelim(find(tmp2))=label(mm,1);
    else,
      labelim(find(mask==mm))=label(mm,1);
    end;
    im_overlay4(im(:,:,1),labelim), drawnow, pause(1),
    tmpgood=1;
  elseif strcmp(tmpin,'s'),
    label(mm,:)=cnt1;
    disp(sprintf(' new label (%d)',cnt1));
    if isstruct(mask),
      labelim(find(tmp2))=label(mm,1);
    else,
      labelim(find(mask==mm))=label(mm,1);
    end;
    im_overlay4(im(:,:,1),labelim), drawnow, pause(1),
    tmpgood=1;
  elseif strcmp(tmpin,'i'),
    disp(sprintf('  ignoring...'));
    tmpgood=1;
  elseif isempty(tmpin),
    disp(sprintf('  ignoring...'));
    tmpgood=1;
  else,
    label(mm,:)=str2num(tmpin);
    if isstruct(mask), 
      labelim(find(tmp2))=label(mm,1);
    else,
      labelim(find(mask==mm))=label(mm,1);
    end;
    im_overlay4(im(:,:,1),labelim), drawnow, pause(1),
    save tmp_masklabel1v cnt1 mm label labelim
    tmpgood=1;
  end;
  if mm==nroi, tmpfound=1; end;
  if tmpgood, mm=mm+1; end;
end;
tmpfound=1;
if exist('tmp_masklabel1v.mat'),
  save tmp_masklabel1v -append tmpfound
else,
  save tmp_masklabel1v mm cnt1 tmpfound label labelim
end;

% now label as Artery Capillary Vein and vessel number for each category
% also decide whether to keep

if exist('tmp_masklabel1v_type.mat'),
  usetmp=input('  tmp type File found, use it (1=Yes, 0=No)?  ');
  if usetmp==1,
    load tmp_masklabel1v_type
  else,
    i1=1; nVa=0; nVc=0; nVv=0;
  end;
else,
  i1=1; nVa=0; nVc=0; nVv=0;
end;
for mm=i1:max(labelim(:)),
  i1=mm;
  tmpi=find(label(:,1)==mm);
  figure(2)
  plot(mean(tc(:,tmpi),2)), axis('tight'), grid('on'), xlabel(num2str(mm)), drawnow,
  figure(1)
  im_overlay4(im(:,:,1),labelim==mm), xlabel(num2str(mm)), drawnow,
  tmpfound=0; tmpA=0; tmpC=0; tmpV=0;
  while(~tmpfound),
    tmpin=input('  type (a,c,v)= ','s');
    tmpfound=1;
    if strcmp(tmpin,'a'),
      nVa=nVa+1; tmpA=1;
    elseif strcmp(tmpin,'c'),
      nVc=nVc+1; tmpC=1;
    elseif strcmp(tmpin,'v'),
      nVv=nVv+1; tmpV=1;
    else,
      tmpfound=0;
    end;
  end;
  tmpin=input('  edit ROIs? (0=no, 1=yes): ','s');
  if strcmp(tmpin,'1'),
    for nn=1:length(tmpi),
      figure(2)
      plot(tc(:,tmpi(nn))),
      figure(1)
      if isstruct(mask),
        [tmp1,tmp2]=getRectImGrid(im(:,:,1),mask(tmpi(nn)));
        im_overlay4(im(:,:,1),tmp2), xlabel(num2str(nn)), drawnow,
      else,
        im_overlay4(im(:,:,1),mask==tmpi(nn)), xlabel(num2str(nn)), drawnow,
      end;
      disp('  press enter...'), pause,
    end;
    tmpin=input('  enter ROIs to exclude, if any: ','s');
    tmpex=str2num(tmpin);
    if ~isempty(tmpex),
      tmpi2=[1:length(tmpi)];
      for nn=1:length(tmpex),
        tmpi2=tmpi2(find(tmpex(nn)~=tmpi2));
      end;
      tmpi=tmpi(tmpi2);
    end;
  end;
  if tmpA, iVa{nVa}=tmpi; lVa{nVa}=mm; end;
  if tmpC, iVc{nVc}=tmpi; lVc{nVc}=mm; end;
  if tmpV, iVv{nVv}=tmpi; lVv{nVv}=mm; end;
  save tmp_masklabel1v_type i1 nV* iV* lV*
end;

if nVa==0, iVa=[]; lVa=[]; end;
if nVc==0, iVc=[]; lVc=[]; end;
if nVv==0, iVv=[]; lVv=[]; end;

nV.a=nVa;
nV.c=nVc;
nV.v=nVv;
nV.ai=lVa;
nV.ci=lVc;
nV.vi=lVv;

iV.a=iVa;
iV.c=iVc;
iV.v=iVv;

if exist('tmp_masklabel1v.mat'),
  unix('rm tmp_masklabel1v.mat');
end;
if exist('tmp_masklabel1v_type.mat'),
  unix('rm tmp_masklabel1v_type.mat');
end;

