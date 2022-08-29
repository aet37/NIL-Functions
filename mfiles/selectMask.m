function [y,ys]=selectMask(im,pos_flag,msk)
% Usage ... [y,ys]=selectMask(im,pos_flag,msk)
%
% pos_flag = check positive thresholds
% pos_flag set to 'check' will check msk

do_check=0;
if nargin==1, pos_flag=1; end;
if ischar(pos_flag), if strcmp(pos_flag,'check'), do_check=1; pos_flag=1; end; end;
if pos_flag<=0, pos_flag=0; end;

y=ones(size(im));
mask=ones(size(im));
im1=im;

smw=[];
thr=[];
hcf=[];

if do_check,
  tmpok=0;
  while(~tmpok),
    clf,
    for mm=1:4, show(im_super(im,msk,0.5*rem(mm-1,2))), drawnow, pause(0.5), end;
    tmpin=input('  mask ok? [0/enter=no, 1=yes]: ');
    if isempty(tmpin), tmpin=0; end;
    if tmpin==1,
      y=msk;
      return;
    elseif tmpin==0,
      disp('  continuing to select mask');
      tmpok=1;
    end;
  end;
end;

tmpok=0;
while(~tmpok),
  clf,
  subplot(121), show(im1),
  subplot(122), show(y),
  tmpin=input('  enter [s=smooth, t/c=thr, f=flat, d/D=draw, i=invert, L=label, w=wlev, r=reset, enter=accept]: ','s');
  if ~isempty(tmpin),
    if strcmp(tmpin,'d'),
      subplot(121), 
      mask=mask&roipoly;
      y=y&mask;
    elseif strcmp(tmpin,'D'),
      subplot(121), 
      if sum(mask(:)==0)<1, mask=roipoly; else, mask=mask|roipoly; end;
      y=mask;
    elseif strcmp(tmpin,'i'),
      y=(~y);
    elseif strcmp(tmpin,'r'),
      im1=im;
      y=ones(size(im));
    elseif strcmp(tmpin,'L'),
      y=bwlabel(y);
    elseif strcmp(tmpin,'A'),
      im1=im1.*(mask>0);
    elseif strcmp(tmpin,'w'),
      disp(sprintf('  wlev-curr=[%f %f], wlev-orig=[%f %f]',min(im1(:)),max(im1(:)),min(im(:)),max(im(:))));
      tmpinw=input('  new wlev= ','s');
      if ~isempty(tmpinw),
          tmpwlev=str2num(['[',tmpinw,']']);
          im1=imwlevel(im1,tmpwlev,0);
      end;
    elseif strcmp(tmpin(1),'c')|strcmp(tmpin(1),'C'),
      y=bwlabel(y>0);
      if length(tmpin)==1, cthr=input(sprintf('    c-thr(min_or_[min,max])(%d)= ',max(y(:)))); else, cthr=num2str(tmpin(2:end)); end;
      for mm=1:max(y(:)), 
        tmpii=find(y==mm);
        if length(cthr)==1,
          if length(tmpii)<cthr(1), y(tmpii)=0; end;
        else,
          if (length(tmpii)<cthr(1))|(length(tmpii)>cthr(2)), y(tmpii)=0; end;
        end;
      end;
      y=y>0;
    elseif strcmp(tmpin,'R'),
      im1=im;
      mask=ones(size(im));
      y=ones(size(im));
    elseif length(tmpin)>1,
      if strcmp(tmpin(1),'t'),
        thr=str2double(tmpin(2:end));
        y=mask&(im1>thr); 
      elseif strcmp(tmpin(1),'s'),
        smw=str2double(tmpin(2:end));
        im1=im_smooth(im1,smw);
      elseif strcmp(tmpin(1),'f')|strcmp(tmpin(1),'h'),
        hcf=str2double(tmpin(2:end));
        im1=homocorOIS(im1,hcf);
      elseif strcmp(tmpin(1),'p'),
        ppe=str2double(tmpin(2:end));
        im1=im1.^ppe; im1=im1/max(im1(:));
      end;
    else,
      tmpin2=input(['  enter ',tmpin,' value= ']);
      if (~isstr(tmpin2))&strcmp(tmpin,'s'),
        smw=tmpin2;
        im1=im_smooth(im,smw);
      elseif (~isstr(tmpin2))&strcmp(tmpin,'c'),
        ct=tmpin2;
        tmpmask=bwlabel(y);
        if length(ct)==1,
          for nn=1:max(tmpmask(:)), tmpii=find(tmpmask==nn); if length(tmpii)<ct, tmpmask(tmpii)=0; end; end;
        else,
          for nn=1:max(tmpmask(:)), tmpii=find(tmpmask==nn); if (length(tmpii)<ct(1))|(length(tmpii)>ct(2)), tmpmask(tmpii)=0; end; end;
        end;
        tmpmask=tmpmask>0;
        y=tmpmask;
      elseif (~isstr(tmpin2))&strcmp(tmpin,'t'),
        thr=tmpin2;
        if pos_flag, y=mask&(im1>thr); else, y=mask&(im1<thr); end;
      elseif (~isstr(tmpin2))&(strcmp(tmpin,'f')|strcmp(tmpin,'h')),
        hcf=tmpin2;
        im1=homocorOIS(im1,hcf);
      elseif (~isstr(tmpin2))&strcmp(tmpin,'p'),
        ppe=tmpin2;
        im1=im1.^ppe; im1=im1/max(im1(:));
      end;
    end;
  else,
    tmpok=1;
  end;
end;

if nargout==2,
  ys.im=im;
  ys.pos_flag=pos_flag;
  ys.thr=thr;
  ys.smw=smw;
  ys.hcf=hcf;
  ys.im1=im1;
  ys.mask=y;
end;

