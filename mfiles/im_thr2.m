function [ylabel,y]=im_thr2(im,thr,cthr)
% Usage ... [ylabel,y]=im_thr2(im,thr,cthr)
%
% generate a mask using threshold thr on im
% thr can be a number or '2.5' for 2.5 std's from the mean im signal or
% 'x0.5' to set the thr to 0.5 of max or 'n0.5' for 0.5 of min
% cthr = [min_pixels_per_region  max_pixels_per_region]
% if cthr is given, the mask is also labeled

%if nargin<3, cthr=1; end;
if ischar(thr),
  thr_orig=thr;
  if strcmp(thr(1),'x'),
    thr=max(im(:))*str2num(thr(2:end));
  elseif strcmp(thr(1),'n'),
    thr=min(im(:))*str2num(thr(2:end));
  elseif strcmp(thr(1),'t'),
    tmpmax=sort(im(:),'decending');
    if strcmp(thr(2),'.')|strcmp(thr(2),'0'),
      tmpf=str2num(thr(2:end));
      tmpthr=floor(tmpf*length(im(:)));
      thr=tmpmax(tmpthr);
    else,
      tmpthr=str2num(thr(2:end));
      thr=tmpmin(tmpthr);
    end;
  elseif strcmp(thr(1),'b'),
    tmpmin=sort(im(:),'ascending');
    if strcmp(thr(2),'.')|strcmp(thr(2),'0'),
      tmpf=str2num(thr(2:end));
      tmpthr=floor(tmpf*length(im(:)));
      thr=tmpmin(tmpthr);
    else,
      tmpthrn=str2num(thr(2:end));
      thr=tmpmin(tmpthr);
    end;
  elseif strcmp(thr(1),'s'),
    thr=std(im(:))*str2num(thr); 
  esle,
    thr=std(im(:))*str2num(thr); 
  end;
  disp(sprintf('  thr: %s , thr= %.3f',thr_orig,thr));
end;

if ~exist('cthr','var'), cthr=[]; end;

if ~isempty(cthr),
  if thr<0,
    y_tmp=bwlabel(im<=thr);
  else,
    y_tmp=bwlabel(im>=thr);
  end;
  for mm=1:max(max(y_tmp)),
    nn(mm)=length(find(y_tmp==mm));
    if (nn(mm)<=cthr), y_tmp(find(y_tmp==mm))=0; end;
    if length(cthr)>1, if (nn(mm)>=cthr(2)), y_tmp(find(y_tmp==mm))=0; end; end;
  end;
  y=(y_tmp>0);
  ylabel=bwlabel(y);
else,
  if thr>0,
    y=im>thr;
  else,
    y=im<thr;
  end;
  ylabel=y;
end;

if nargout==0,
  %subplot(211)
  %show(y)
  %subplot(212)
  %for mm=1:max(max(ylabel)),
  %  show(ylabel==mm),
  %  xlabel(sprintf('%d',mm)),
  %  pause,
  %end;
  show(ylabel)
  for mm=1:max(double(ylabel(:))),
    clear tmpi tmpj
    [tmpi,tmpj]=find(ylabel==mm); 
    text(mean(tmpi),mean(tmpj),num2str(mm),'Color','red'); 
    %text(mean(tmpi)+0.02*size(ylabel,1),mean(tmpj)-0.04*size(ylabel,2),num2str(mm),'Color','red'); 
  end;
  clear ylabel
end;

