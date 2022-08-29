function y=imwlevel(x,level,norm,mycmap)
% Usage ... y=imwlevel(x,level,norm,mycmap)
%
% Image window level adjust function. X is an image whether 2D or
% multi-channel (upto 3ch). If 3ch, norm is set to 1.
% level can be direct numbers in a [min max] vector,
% it can also be a string, for ex 'x0.9', 'n0.1', '0, 0.9'


if ~exist('level'), level=''; end;
if nargin<4, mycmap=''; end;
if nargin<3, norm=''; end;

do_rgb=0;
if ~isempty(mycmap), do_rgb=1; end;

xdim=size(x);

if isempty(level),
  if length(xdim)==3,
    level=[min(min(min(x))) max(max(max(x)))];
  else,
    level=[min(min(x)) max(max(x))];
  end;
  disp(sprintf('  level= [%.4f %.4f]',level(1),level(2)));
elseif ischar(level)
  tmplevel=[min(x(:)) max(x(:))];
  if strcmp(level(1),'x'),
    newlevel=tmplevel(1)+(tmplevel(2)-tmplevel(1))*[0 str2num(level(2:end))];
  elseif strcmp(level(1),'n'),
    newlevel=tmplevel(1)+(tmplevel(2)-tmplevel(1))*[str2num(level(2:end)) 1];
  else,
    tmpnum=str2num(level);
    if length(tmpnum)==2,
      newlevel=tmplevel(1)+(tmplevel(2)-tmplevel(1)).*tmpnum;
    else,
      disp('  warning: did not recognize wlevel string');
      newlevel=tmplevel;
    end;
  end;
  level=newlevel;
  disp(sprintf('  level= [%.4f %.4f]',level(1),level(2)));
end;

if (length(xdim)==3)&(xdim(3)==2), x(:,:,3)=0; end;
if (length(xdim)==3)&(xdim(3)>4), x=x(:,:,1:3); end;

if length(xdim)==3,
  % forces image to go between 0 and 1 for display
  y=x-level(1);
  y=y/level(2);
  y(find(y<0))=0;
  y(find(y>1))=1;
else,
  y = level(1)*(x<=level(1)) + level(2)*(x>=level(2)) + x.*((x>level(1))&(x<level(2)));
end;

if ~isempty(norm),
  if norm,
  y=y-min(y(:));
  y=y/max(y(:));
  end
end;

if do_rgb,
  y=ind2rgb(y,mycmap);
end;

