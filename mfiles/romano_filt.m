function filt = romano_filt(nx,ny,nz)

[xx yy zz]=meshgrid(-1:(2/(nx+1)):1,-1:(2/(ny+1)):1,-1:(2/(nz+1)):1);
filt = (1-xx.^2).^2 .* (1-yy.^2).^2 .* (1-zz.^2).^2;
filt = filt(2:end-1,2:end-1,2:end-1);
filt = filt/sum(filt(:));