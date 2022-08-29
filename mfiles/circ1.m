function im=circ1(inmat,r,c)
% Usage ... im=circ1(inmat,r,center)

im=zeros(size(inmat));
im(c(1),c(2))=1;
ddim=bwdist(im);
ii=find(ddim<=r);
if ~isempty(ii),
  im(ii)=1;
end;

