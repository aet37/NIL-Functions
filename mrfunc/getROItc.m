function [y,ys]=getROItc(data,mask,exclv)
% Usage ... y=getROItc(data,mask,exclv)
%
% Exclude criteria=[imthr smw ndil]

do_excl=0;
if nargin>2, do_excl=1; end;

y=zeros(size(data,3),max(mask(:)));
ys=y;

for mm=1:size(data,3),
  tmpim=data(:,:,mm);
  if do_excl, 
    tmpmaske=im_smooth(tmpim,exclv(2))>exclv(1); 
    if sum(tmpmaske(:))>2, tmpmaske=imdilate(tmpmaske,ones(exclv(3),exclv(3))); end;
  else,
    tmpmaske=zeros(size(tmpim));
  end;
  for nn=1:max(mask(:)),
    tmpii=find((mask==nn).*(~tmpmaske));
    if length(tmpii)>0,
      y(mm,nn)=mean(tmpim(tmpii));
      ys(mm,nn)=std(tmpim(tmpii));
    end;
  end;
end;


