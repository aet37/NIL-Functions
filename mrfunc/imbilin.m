function g=imbilin(im,factor)
% Usage ... g=imbilin(im,factor)
%
% Factor will be either 2 or 4 (zoom up only, for now...)
% Assumes linear evenly spaced scale

isize=size(im);
nsize=factor*isize;

for j=1:isize(2),
  f(:,2*j-1)=im(:,j);
end;
for i=1:isize(1),
  for j=1:isize(2)-1,
    f(i,2*j)=0.5*(f(i,2*j-1)+f(i,2*j+1));
  end;
end;
for i=1:isize(1),
  f(i,nsize(2))=0.5*(f(i,nsize(2)-1)+f(i,1));
end;

for i=1:isize(1),
  g(2*i-1,:)=f(i,:);
end;
for i=1:isize(2)-1,
  for j=1:nsize(2),
    g(2*i,j)=0.5*(g(2*i-1,j)+g(2*i+1,j));
  end;
end;
for j=1:nsize(2),
  g(nsize(1),j)=0.5*(g(nsize(1)-1,j)+g(1,j));
end;

clear f
