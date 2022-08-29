function fatlines(wid,ii,sty)
% Usage ... fatlines(wid,ii,sty)
%
% wid is the width, ii is the line number, sty is the style
% default width is 1.25

dlha = get(gca,'children');
if nargin==0, wid=2; end;
if isempty(wid), disp(sprintf(' #lines= %d',length(dlha))); return, end;
if ~exist('ii','var'), ii=[1:length(dlha)]; end;
if isempty(ii), disp(sprintf(' #lines= %d',length(dlha))); elseif iscell(ii), sty=ii; ii=[1:length(dlha)]; end;
if length(wid)>1,
  %wid=wid(end:-1:1);
  for mm=1:length(wid), if wid(mm)>0, set(dlha(end-mm+1),'LineWidth',wid(mm)); end; end;
else,
  set(dlha(ii),'LineWidth',wid);
end;
if exist('sty','var'),
  for mm=1:length(sty), if ~isempty(sty{mm}), set(dlha(end-mm+1),'LineStyle',sty{mm}); end; end;
end;
clear dlha
