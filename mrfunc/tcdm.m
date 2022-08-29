function out=tcdm(filename,finfo,slice,pix)
%
% Usage .. out=tcdm(filename,finfo,slice,pix)
%
% finfo=[no-slices no-images xdim ydim]
% pix - pixels to be evaluated along with their weights
% Assumes ordered by slice-image number
%

fid=fopen(filename,'r');
imstrsz=2;
back_off=(finfo(1))*finfo(2)*finfo(3)*finfo(4)*imstrsz;
pix_size=size(pix);
im_size=imstrsz*finfo(3)*finfo(4);
sl_size=im_size*finfo(1)*finfo(2);
tmploc=back_off;
tmptc=zeros([finfo(1) finfo(2)]);

for n=1:finfo(2),
tmpsum=0;
tmpval=0;
tmpwt=0;
tmpwtsum=0;
for o=1:pix_size(1),
  tmploc=back_off - (n-1)*im_size - imstrsz*( finfo(3)*(pix(o,1)-1)+pix(o,2) );
  fseek(fid,tmploc,1);
  tmpval=fread(fid,1,'short');
  tmpwt=pix(o,3);
  tmpval=tmpval*tmpwt;  
  tmpsum=tmpsum+tmpval;
  tmpwtsum=tmpwtsum+tmpwt;
end;
tmptc(m,n)=tmpsum/tmpwtsum;
end;

out=tmptc;

fclose(fid);
