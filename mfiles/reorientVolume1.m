function [y,y2]=reorientVolume1(data,parm)
% Usage ... [y,xx_ro]=reorientVolume1(data,parm)
%
% parm = x0 y0 z0 r_x r_y r_z  or 'select' (default)
% (order: rz, ry; rx - ry>0 CCW, rz>0 CCW, rx>0 CW rotations)
%
% when using select mode, first figure out individual parameters
% then select keep and enter each desired orientation parameter

data=squeeze(data);

if nargin<2, parm=[]; end;
if isempty(parm), parm='select'; end;

if (~ischar(parm))&(length(parm)==6),
  if length(size(data))==4,
    y=data;
    for mm=1:size(data,3),
      if sum(abs(parm(4:6)))>1e-3,
        y(:,:,mm,:)=rot3d_nf(y(:,:,mm,:),[parm(4:6)]);
      end;
      if sum(abs(parm(1:3)))>1e-3,
        y(:,:,mm,:)=volshift2(y(:,:,mm,:),[parm(1:3)]);
      end;
    end;
  else,
    y=data;
    if sum(abs(parm(4:6)))>1e-3, y=rot3d_nf(y,[parm(4:6)]); end;
    if sum(abs(parm(1:3)))>1e-3, y=volshift2(y,[parm(1:3)]); end;
  end;
  return;
end;

if ischar(parm),
  if strcmp(parm,'select'),
    rparm=[0 0 0];
    dparm=[0 0 0];
    tmpdata=data;
    clf; tmpfig=gcf;
    do_keep=0; do_calc=1;
    tmpwl=[];
    tmpok=0;
    while(~tmpok),
      figure(tmpfig), clf, showProj(tmpdata), subplot(221), xlabel('z-proj (rz)'), subplot(222), xlabel('y-proj (ry)'), subplot(223), xlabel('x-proj (rx)'), drawnow,
      disp(sprintf('  [xx=%.2f yy=%.2f zz=%.2f  rx=%.2f ry=%.2f rz=%.2f] keep=%d',dparm(1),dparm(2),dparm(3),rparm(1),rparm(2),rparm(3),do_keep));
      tmpin=input('  select [enter] m a R q xx# yy# zz# rx# ry# rz#: ','s');
      if isempty(tmpin),
        tmpok=1;
      elseif length(tmpin)==1,
        if strcmp(tmpin(1),'q'),
          tmpok=1;
        elseif strcmp(tmpin(1),'s'),
          showStack(tmpdata);
        elseif strcmp(tmpin(1),'m'),
          figure(tmpfig), [tmpx,tmpy]=round(ginput(1));
          disp(sprintf('  m= (%.2f, %.2f)',tmpx,tmpy));
        elseif strcmp(tmpin(1),'a'),
          figure(tmpfig), tmpang=myangle2;
        elseif strcmp(tmpin(1),'r')|strcmp(tmpin(1),'R'),
          tmpdata=data; rparm=[0 0 0]; dparm=[0 0 0];
        elseif strcmp(tmpin(1),'k'),
          do_keep=~do_keep; do_calc=0;
        elseif strcmp(tmpin(1),'w'),
          tmpin2=input(sprintf('  current [%.2f,%.2f], enter new wlev= ',min(tmpdata(:)),max(tmpdata(:))),'s');
          tmpwl=str2num(['[',tmpin2,']',]);
          %tmpdata=volwlevel(tmpdata,tmpwl);
        end;
      else,
        if (~do_keep), dparm=[0 0 0]; rparm=[0 0 0]; end;
        if length(tmpin)==2, 
          tmpnum=input(sprintf('  %s value= ',tmpin));
        else,
          tmpnum=str2num(tmpin(3:end));
        end;
        if strcmp(tmpin(1:2),'xx'), dparm(1)=tmpnum;
        elseif strcmp(tmpin(1:2),'yy'), dparm(2)=tmpnum;
        elseif strcmp(tmpin(1:2),'zz'), dparm(3)=tmpnum;
        elseif strcmp(tmpin(1:2),'rx'), rparm(1)=tmpnum;
        elseif strcmp(tmpin(1:2),'ry'), rparm(2)=tmpnum;
        elseif strcmp(tmpin(1:2),'rz'), rparm(3)=tmpnum;
        end;
      end;
      if (~tmpok)&(do_calc),
        %if (~do_keep), tmpdata=data; end;
        if (sum(abs(rparm))>1e-3),
          tmpdata=rot3d_nf(data,rparm);
        else,
          tmpdata=data;
        end;
        if (sum(abs(dparm))>1e-3),
          tmpdata=volshift2(tmpdata,dparm);
        end;
      end;
      if ~isempty(tmpwl), tmpdata=volwlevel(tmpdata,tmpwl,0); end;
      do_calc=1;
    end;
    y2=[dparm rparm];
    y=tmpdata;
  end;
end;

if nargout==0,
  showProj(y),
  clear y
end;

