function mysavetiff16(x,fname)
% Usage ... mysavetiff16(x,fname)

uint16_max=65535;

x=x-min(x(:)); 
x=x/max(x(:));
x=uint16(round(x*uint16_max));

if strcmp(fname(end-4:end),'.tif')|strcmp(fname(end-4:end),'.TIF')|strcmp(fname(end-4:end),'tiff'), 
  fname=[fname,'.tif'];
end;

for mm=1:size(x,3),
  if mm==1,
    imwrite(x(:,:,mm),fname,'Compression','None');
  else,
    imwrite(x(:,:,mm),fname,'Compression','None','WriteMode','append');
  end;
end;

