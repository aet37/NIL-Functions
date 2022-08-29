function [y,myax]=mycropim(im,ax)
% Usage ... y=mycropim(im,ax)

if (length(ax)==4),
  myax=ax;
else,
  [i1,j1]=find(ax);
  myax=[min(i1) max(i1) min(j1) max(j1)];
end;

y=im(myax(1):myax(2),myax(3):myax(4));

if (nargout==0),
  show(y)
  xlabel(sprintf('[%d %d %d %d]',myax))
  clear y
end

