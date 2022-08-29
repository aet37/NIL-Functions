function y=showStack(stk,ip1,ip2,ip3,ip4,ip5,ip6,ip7,ip8,ip9,ip10,ip11,ip12,ip13,ip14)
% Usage ... showStack(stk,options)
%
% Options: 'axis','overlay','projscale','wl'
% Window Functions: g=goto, m=mark, p=proj_square, w=wlevel, q=quit

vars={'axis','overlay','projscale','wl'};

% parse these-settings
for mm=1:length(vars), eval(sprintf('do_%s=0;',vars{mm})); end;
for mm=1:nargin-1,
  for nn=1:length(vars),
    eval(sprintf('tmptest=strcmp(ip%d,''%s'');',mm,vars{nn}));
    if tmptest,
      disp(sprintf('do_%s=1;',vars{nn}));
      eval(sprintf('do_%s=1;',vars{nn}));
      if mm<nargin-1,
        eval(sprintf('%s_parms=ip%d;',vars{nn},mm+1));
        eval(sprintf('tmptest2=ip%d;',mm+1));
        if isstr(tmptest2),
          disp(sprintf('%s_parms=[];',vars{nn}));
          eval(sprintf('%s_parms=[];',vars{nn}));
        else,
          disp(sprintf('%s_parms=ip%d;',vars{nn},mm+1));
          eval(sprintf('%s_parms=ip%d;',vars{nn},mm+1));
        end;
      else,
        eval(sprintf('%s_parms=[];',vars{nn}(4:end)));
      end;
    end;
  end;
end;

stk=squeeze(stk);
if ~iscell(stk)&size(stk,3)<=1,
  disp('  dimension 3 is not of sufficient size...'),
  return,
end;

S.fh=figure('keypressfcn',@fh_kpfcn);
%S.tx=uicontrol('style','text');
S.stk=stk;
S.sdim=size(stk);
S.mm=1;
if iscell(S.stk), S.sdim=size(stk{1}); S.sdim(end+1)=length(S.stk); end;
S.fp=[];
S.pparm=[];
S.markim=[];
S.do_color=0;
if do_wl, S.wlevel=wl_parms; else, S.wlevel=[]; end;

if do_axis, 
    S.ax=axis_parms; 
else, 
    %S.ax=[1 S.sdim(1) 1 S.sdim(2)]; 
    S.ax=[]; 
end;

if do_overlay, 
    S.do_overlay=1; S.ov=overlay_parms; 
else, 
    S.do_overlay=0; S.ov=[]; 
end;
if do_projscale, S.pparms=projscale_parms; else, S.pparm=[2 2 4 2]; end;

if length(S.sdim)==4, S.do_color=1; end;
if iscell(S.stk), if length(size(S.stk{1}))>2, S.do_color=1; end; end;

if S.do_color,
  if length(S.sdim)==4, S.pdim=S.sdim([1 2 4]).*[0.1 0.1 0.2]; else, S.pdim=S.sdim.*[0.1 0.1 0.2]; end;
else,
  S.pdim=S.sdim.*[0.1 0.1 0.2];
end;

if S.do_color,
  if iscell(S.stk), myshow(S.stk{1},S.wlevel), else, myshow(S.stk(:,:,:,1),S.wlevel), end
  if ~isempty(S.ax), axis(S.ax), end;
  xlabel(sprintf('%d/%d',S.mm,S.sdim(4))), drawnow;
else,
  if iscell(S.stk), myshow(S.stk{1},S.wlevel), else, myshow(S.stk(:,:,1),S.wlevel), end
  if ~isempty(S.ax), axis(S.ax), end;
  xlabel(sprintf('%d/%d',S.mm,S.sdim(3))), drawnow;
end;
guidata(S.fh,S)

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
      case 'g'
          tmpin=input('  enter #: ');
          S.mm=tmpin; tmpupdate=1;
      case 'm'
          [tmpi,tmpj]=ginput(1); tmpi=round(tmpi); tmpj=round(tmpj);
          disp(sprintf('  [%d,%d,%d]= %f',tmpi,tmpj,S.mm,S.stk(tmpj,tmpi,S.mm)));
          if isempty(S.markim), S.markim=zeros(size(S.stk,1),size(S.stk,2)); end;
          S.markim(tmpj,tmpi)=1-S.markim(tmpj,tmpi);
          if S.do_color,
            im_overlay4(S.stk(:,:,1,S.mm),imdilate(S.markim,strel('disk',ceil(0.03*size(S.markim,1)))));
          else,
            im_overlay4(S.stk(:,:,S.mm),imdilate(S.markim,strel('disk',ceil(0.03*size(S.markim,1)))));
          end;
          pause(0.4);
      case 'p'
          [tmpi,tmpj]=ginput(1); tmpi=round(tmpi); tmpj=round(tmpj); tmpk=S.mm;
          disp(sprintf('  [%d,%d,%d]= %f',tmpi,tmpj,S.mm,S.stk(tmpj,tmpi,S.mm)));
          if isempty(S.fp), S.fp=figure; end;
          tmpsi=tmpj+[-floor(S.pdim(1)/2):floor(S.pdim(1)/2)];
          tmpsj=tmpi+[-floor(S.pdim(2)/2):floor(S.pdim(2)/2)];
          tmpsk=S.mm+[-floor(S.pdim(3)/2):floor(S.pdim(3)/2)];
          if length(find(tmpsi<1))>0, tmpsi(find(tmpsi<1))=1; end;
          if length(find(tmpsj<1))>0, tmpsj(find(tmpsj<1))=1; end;
          if length(find(tmpsk<1))>0, tmpsk(find(tmpsk<1))=1; end;
          if length(find(tmpsi>S.sdim(1)))>0, tmpsi(find(tmpsi>S.sdim(1)))=S.sdim(1); end;
          if length(find(tmpsj>S.sdim(2)))>0, tmpsj(find(tmpsj>S.sdim(2)))=S.sdim(2); end;
          if length(find(tmpsk>S.sdim(end)))>0, tmpsk(find(tmpsk<S.sdim(end)))=S.sdim(end); end;
          if S.do_color,
            tmpstk=S.stk(tmpsi,tmpsj,:,tmpsk);
            for oo=1:S.sdim(3),
              tmpstk2(:,:,oo,:)=myvolinterpf(S.stk(tmpsi,tmpsj,tmpsk).^S.pparm(4),S.pparm(1:3));
            end;
          else,
            tmpstk=S.stk(tmpsi,tmpsj,tmpsk);
            tmpstk2=myvolinterpf(S.stk(tmpsi,tmpsj,tmpsk).^S.pparm(4),S.pparm(1:3));
          end;
          figure(S.fp), showProj(tmpstk2);
          figure(S.fh),
          guidata(H,S);
          save tmpstkproj tmpi tmpj tmpk tmpstk tmpstk2
      case {'y','Y'}
          [tmpj,tmpi]=ginput(1); tmpi=round(tmpi); tmpj=round(tmpj); tmpk=S.mm;
          disp(sprintf('  [%d,%d,%d]= %f',tmpi,tmpj,S.mm,S.stk(tmpj,tmpi,S.mm)));
          if isempty(S.fp), S.fp=figure; end;
          if tmpi<1, tmpi=1; end; if tmpi>S.sdim(1), tmpi=S.sdim(1); end;
          if tmpj<1, tmpj=1; end; if tmpj>S.sdim(2), tmpj=S.sdim(2); end;
          %S.pparm([1 3]),
          if S.do_color,
            for oo=1:S.sdim(3),
              tmpstk2(:,:,oo)=myiminterpf(squeeze(S.stk(:,tmpj,oo,:)),S.pparm([3 1]));
            end;
          else,
            tmpstk2=myiminterpf(squeeze(S.stk(:,tmpj,:)),S.pparm([3 1]));
          end;
          tmpstk2=abs(tmpstk2);
          figure(S.fp), myshow(tmpstk2);
          figure(S.fh),
          guidata(H,S);
      case {'x','X'}
          [tmpj,tmpi]=ginput(1); tmpi=round(tmpi); tmpj=round(tmpj); tmpk=S.mm;
          disp(sprintf('  [%d,%d,%d]= %f',tmpi,tmpj,S.mm,S.stk(tmpj,tmpi,S.mm)));
          if isempty(S.fp), S.fp=figure; end;
          if tmpi<1, tmpi=1; end; if tmpi>S.sdim(1), tmpi=S.sdim(1); end;
          if tmpj<1, tmpj=1; end; if tmpj>S.sdim(2), tmpj=S.sdim(2); end;
          %S.pparm([2 3]),
          if S.do_color,
            for oo=1:S.sdim(3),
              tmpstk2(:,:,oo)=myiminterpf(squeeze(S.stk(tmpi,:,oo,:)),S.pparm([3 2]))';
            end;
          else,
            tmpstk2=myiminterpf(squeeze(S.stk(tmpi,:,:)),S.pparm([3 2]))';
          end;
          tmpstk2=abs(tmpstk2);
          figure(S.fp), myshow(tmpstk2);
          figure(S.fh),
          guidata(H,S);
      case 'o'
          S.do_overlay=(~S.do_overlay);
          tmpupdate=1;
          %if ~isempty(S.ov),
          %  if length(size(S.ov))>2, oo=S.mm; else, oo=1; end;
          %  if S.do_color,
          %    im_overlay4(S.stk(:,:,1,S.mm),S.ov(:,:,oo)), axis(S.ax), drawnow, %pause(0.4),
          %  else,
          %    im_overlay4(S.stk(:,:,S.mm),S.ov(:,:,oo)), axis(S.ax), drawnow, %pause(0.4),
          %  end;
          %end;
      case 'w'
          tmpin=input('  enter wlevel [min max]= ','s');
          tmpin=['[',tmpin,']'];
          S.wlevel=str2num(tmpin);
          tmpupdate=1;
          guidata(H,S);
      case {'q','Q'}
          tmpexit=1;
  end;
  %disp(sprintf('%d/%d',S.mm,S.sdim(3)));
  if tmpexit,
    close(H);
    if ~isempty(S.fp), close(S.fp); end;
  end;
  if tmpupdate,
    if S.mm<1,
      S.mm=1;
    elseif S.mm>S.sdim(end),
      S.mm=S.sdim(end);
    else,
      %S.wlevel,
      if S.do_color,
        if iscell(S.stk), myshow(S.stk{S.mm},S.wlevel), else, myshow(S.stk(:,:,:,S.mm),S.wlevel), end
        if ~isempty(S.ax), axis(S.ax), end;
        xlabel(sprintf('%d/%d',S.mm,S.sdim(4))), drawnow;
      elseif S.do_overlay,
        if ~isempty(S.ov),
          if length(size(S.ov))>2, oo=S.mm; else, oo=1; end;
          if S.do_color,
            im_overlay4(S.stk(:,:,1,S.mm),S.ov(:,:,oo)), 
            if ~isempty(S.ax), axis(S.ax), end; drawnow, %pause(0.4),
          else,
            im_overlay4(S.stk(:,:,S.mm),S.ov(:,:,oo)), 
            if ~isempty(S.ax), axis(S.ax), end; drawnow, %pause(0.4),
          end;
       end;
      else,
        if iscell(S.stk), myshow(S.stk{S.mm},S.wlevel), else, myshow(S.stk(:,:,S.mm),S.wlevel), end
        if ~isempty(S.ax), axis(S.ax), end;
        xlabel(sprintf('%d/%d',S.mm,S.sdim(3))), drawnow;
      end;
    end;
    guidata(H,S)
    uiresume(H);
  end;
  y=S.markim;

function myshow(a,level)
  if isempty(a), a=[0]; end;
  if nargin==1,
    level=[min(a(:)) max(a(:))];
    if abs(level(2)-level(1))<1e-10, level=[level(1) level(1)+1]; end;
  end;
  if isempty(level),
    level=[min(a(:)) max(a(:))];
    if abs(level(2)-level(1))<1e-10, level=[level(1) level(1)+1]; end;
  end;    
  adim=size(a);
  if length(adim)==3,
    a3=adim(3); 
    if (a3<=3)|(a3>4),
      tmpim=zeros(adim(1),adim(2),3);
      tmpim(:,:,1:a3)=a(:,:,1:a3);
      image(imwlevel(tmpim,level,1)),
    else,
      tmpim=zeros(adim(1),adim(2),3);
      tmpim(:,:,[2 3])=a(:,:,[3 4]);
      tmpim(:,:,1)=mean(a(:,:,[1 2]),3);
      image(imwlevel(tmpim,level,1)),        
    end;
  else,
    imagesc(a,level),
    colormap(gray);
  end;
  title(sprintf('min/max= %f/%f',level(1),level(2)));
  axis('image');
  grid('on');


