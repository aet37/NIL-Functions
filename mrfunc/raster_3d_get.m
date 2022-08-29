function f=raster_3d_get(matrix,row,col,skip)
% f=raster_3d_get(matrix,row,col,skip)
% skip (n+1) columns 1-4 (skip=3)

[mr,mc]=size(matrix);

for n=1:floor(mc/skip),
  f(n)=matrix(row,col+(n-1)*skip);
end;    