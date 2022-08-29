function [labelim,label,labelim_orig]=maskLabel1(mask,im,prev)
% Usage ... [labelim,label,labelim_orig]=maskLabel1(mask,im,prev)

if iscell(mask),
  labelim=double(mask{1}>0);
  tmplab=bwlabel(labelim);
  if length(mask)>1, for mm=2:length(mask),
    tmplab2=bwlabel(mask{mm}>0);
    for nn=1:max(tmplab(:)), for oo=1:max(tmplab2(:)),
      if sum(sum(double((tmplab==nn).*(tmplab2==oo)))),
        labelim(find(tmplab==nn))=mm;
      end;
    end; end;
  end; end;
  tmpmask=mask{1};
  clear mask
  mask=tmpmask;
else,  
  labelim=mask>0;
end;
labelim=double(labelim);

use_prev=0;
if exist('prev'),
  if size(prev,1)==max(mask(:)),
    % label id being provided
    use_prev=2;
    for mm=1:max(mask(:)), 
      tmplabel(mm)=prev(mm,1)+2*prev(mm,2);
      labelim(find(mask==mm))=tmplabel(mm);
    end;
  else,
    % assume image is provided
    use_prev=1;
    labelim=prev;
  end;
end;

if exist('tmp_masklabel1.mat'),
  usetmp=input('  tmp File found, use it (1=Yes, 0=No)?  ');
  if usetmp==1,
    load tmp_masklabel1 labelim
  end;
end;

imdim=size(im);

% label: neuron=1, astrocyte=2, neuron_by_vessel=3, astrocyte_by_vessel=4 

mm=1;
tmpfound=0;
while(~tmpfound),
  im_overlay4(im(:,:,1),labelim,256)
  [tmpy,tmpx,tmpbut]=ginput(1);
  tmpx=round(tmpx); tmpy=round(tmpy);
  tmpedit=1;
  if (tmpx<1)|(tmpx>imdim(1)), tmpedit=0; tmpfound=1; end;
  if (tmpy<1)|(tmpy>imdim(2)), tmpedit=0; tmpfound=1; end;
  if (tmpbut==3)&(tmpedit),
    for oo=1:2,
      show(im(:,:,1)), drawnow, pause(0.3),
      show(im(:,:,2)), drawnow, pause(0.3),
    end;
  elseif tmpedit,
    if labelim(tmpx,tmpy)>0,
      tmpmaski=mask(tmpx,tmpy);
      tmpii=find(mask==tmpmaski);
      if labelim(tmpx,tmpy)==4,
        labelim(tmpii)=1;
      else,
        labelim(tmpii)=labelim(tmpx,tmpy)+1;
      end;
    end;
    if labelim(tmpx,tmpy)==1, disp('  id= 1 (n)'); end;
    if labelim(tmpx,tmpy)==2, disp('  id= 2 (a)'); end;
    if labelim(tmpx,tmpy)==3, disp('  id= 3 (nv)'); end;
    if labelim(tmpx,tmpy)==4, disp('  id= 4 (av)'); end;
    save tmp_masklabel1 labelim
  end;
end;

verify_flag=input('  verify? (1=yes, 0=no): ');
if isempty(verify_flag), verify_flag=0; end;

labelim_orig=labelim;
label=zeros(max(mask(:)),2);

if verify_flag,
  tmpfound=0;
  mm=1;
  while(~tmpfound),
    tmpgood=0;
    while(~tmpgood),
      tmpii=find(mask==mm);
      tmplabel=max(labelim(tmpii));
      im_overlay4(im(:,:,1),(mask==mm).*labelim),
      drawnow, pause(0.2), show(im(:,:,2)), drawnow, pause(0.2), show(im(:,:,1)), drawnow, pause(0.2),
      im_overlay4(im(:,:,1),(mask==mm).*labelim),
      xlabel(num2str(mm)),      
      tmpin=input(sprintf('  id=%d ok? (enter or new_label [1-4], f=flash, b=back): ',tmplabel),'s');
      tmpgood=1;
      if ~isempty(tmpin),
        tmpgood=0; 
        if strcmp(tmpin,'f'),
          for oo=1:2,
            show(im(:,:,1)), drawnow, pause(0.3),
            show(im(:,:,2)), drawnow, pause(0.3),
          end;
        elseif strcmp(tmpin,'b'),   % back
          mm=mm-1;
        elseif strcmp(tmpin,'n'),   % next
          mm=mm+1; disp(sprintf('  %d of %d',mm,max(mask(:))));
        elseif strcmp(tmpin(1),'g'),    % goto
          mm=str2num(tmpin(2:end));
        elseif strcmp(tmpin(1),'e'),    % edit
          mask=bwlabel(editmask(mask>0,im));
          if mm>1,
            tmplabelim0=mask>0;
            for nn=1:mm-1, tmplabelim0(find(mask==nn))=max(labelim(find(mask==nn))); end;
            disp('  updating labelim...');
            labelim_prev=labelim;
            labelim=tmplabelim0;
          end;
        else,
          tmpin=str2num(tmpin);
          labelim(tmpii)=tmpin;
          save tmp_masklabel1 labelim
          mm=mm+1;
        end;
      else,
        mm=mm+1;
      end;
      if mm>max(mask(:)), tmpfound=1; tmpgood=1; end;
    end;
  end;
end;

for mm=1:max(mask(:)),
  tmpii=find(mask==mm);
  tmplabel=max(labelim(tmpii));
  if tmplabel==1, label(mm,:)=[1 0]; end;
  if tmplabel==2, label(mm,:)=[2 0]; end;
  if tmplabel==3, label(mm,:)=[1 1]; labelim(tmpii)=1; end;
  if tmplabel==4, label(mm,:)=[2 1]; labelim(tmpii)=2; end;
end;

if exist('tmp_masklabel1.mat'),
  unix('rm tmp_masklabel1.mat');
end;

