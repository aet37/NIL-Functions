function [yi,y]=getTriggers(x,thr)
% Usage ... [yi,y]=getTriggers(x,thr)
%
% thr=[thr_for_x thr_for_diff]

if nargin==1, thr=[1 2]; end;
if length(thr)==1, thr(2)=2; end;

y=zeros(size(x));

x=x(:);
tmpii=find(x>thr(1));
tmpdi=find(diff(tmpii)>thr(2));
tmpii2=[tmpii(1)];
if length(tmpdi)>0,
  tmpii2=[tmpii2; tmpii(tmpdi+1)];
end;

yi=tmpii2;
y(yi)=1;

if nargout==0,
  plot([x(:) y(:)*thr(1)+x(1)]),
  clear y yi
end;
