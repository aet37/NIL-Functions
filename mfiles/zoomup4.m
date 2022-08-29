function y=zoomup4(im)
% usage ... im2=zoomup4(im)

dim=size(im);
y1=zeros([dim(1)*4 dim(2)]);
y=zeros(4*dim);

for m=1:dim(1),
  for n=1:dim(2),
    y1(4*m-3:4*m,n)=im(m,n)*ones([4 1]);
  end;
end;
for m=1:4*dim(1),
  for n=1:dim(2),
    y(m,4*n-3:4*n)=y1(m,n)*ones([1 4]);
  end;
end;

