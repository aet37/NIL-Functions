function im=mkcrossim(locs,imsize,plen)
% Usage ... im=mkcrossim(locs,imsize,pix_len)

if nargin<3, plen=1; end;

im=zeros(imsize);
for mm=1:size(locs,1),
  im(locs(mm,1),locs(mm,2))=1;
  if (plen>0),
    ii1=[locs(mm,1)-plen:locs(mm,1)+plen];
    ii2=[locs(mm,2)-plen:locs(mm,2)+plen];
    im(ii1,locs(mm,2))=1;
    im(locs(mm,1),ii2)=1;
  end;
end;

