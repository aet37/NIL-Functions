function y=imflip(im,flipdir)
% Usage ... y=imflip(im,flipdir)

if (nargin<2), flipdir=1; end;

if (ischar(flipdir)),
  if (flipdir=='x')|(flipdir=='r')|(flipdir=='ud'), flipdir=1; 
  elseif (flipdir=='y')|(flipdir=='c')|(flipdir=='lr'), flipdir=2; 
  else, flipdir=1;
  end;
end;

xdim=size(im,1);
ydim=size(im,2);

y=zeros(size(im));

if (flipdir==2),
  for n=1:ydim,
    y(:,n)=im(:,ydim-n+1);
  end;
else,
  for m=1:xdim,
    y(m,:)=im(xdim-m+1,:);
  end;
end;

