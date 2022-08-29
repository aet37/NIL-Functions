function g=replicate2d(im,factor)
% Usage ... g=replicate2d(im,factor)
%
% Factor will be either 2 or 4 (zoom up only, for now...)
% Assumes linear evenly spaced scale

isize=size(im);
nsize=factor*isize;

for j=1:isize(2),
  f(:,2*j-1)=im(:,j);
end;
for i=1:isize(1),
  for j=1:isize(2),
    f(i,2*j)=f(i,2*j-1);
  end;
end;

for i=1:isize(1),
  g(2*i-1,:)=f(i,:);
end;
for i=1:isize(2),
  for j=1:nsize(2),
    g(2*i,j)=g(2*i-1,j);
  end;
end;

clear f
