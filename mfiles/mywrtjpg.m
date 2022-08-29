function mywrtjpg(a,fname,qlty,wlev)
% usage ... mywrtjpg(a,fname,qlty,wlev)

if nargin<4,
  amin=min(min(a));
  amax=max(max(a));
else,
  amin=wlev(1);
  amax=wlev(2);
end;

if nargin<3, qlty=90; end;

a=255*(a-amin)/(amax-amin);

imwrite(uint8(round(a')),fname,'jpg','Quality',qlty)

