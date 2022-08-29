function y=imlocalmax(im,parms)
% Usage ... y=imlocalmax(im,parms)
%
% parms = [neighborhood(default=3) maxmin_flag(default=1=max_only,2=max-min,-1=min)]

if nargin==1, parms=[3 1]; end;
if length(parms)==1, parms(2)=1; end;
maxmin_flag=parms(2);

neig=parms(1);
i1=floor(neig/2);
i2=i1+rem(neig,2)-1;

y=zeros(size(im));
for mm=1+i1:size(im,1)-i2, for nn=1+i1:size(im,2)-i2,
  tmpreg=im([-i1:i2]+mm,[-i1:i2]+nn);
  if (max(tmpreg(:))==im(mm,nn)), y(mm,nn)=1; end;
  if (min(tmpreg(:))==im(mm,nn)), y(mm,nn)=-1; end;
end; end;

if maxmin_flag==1,
  y=y==1;
elseif maxmin_flag==-1,
  y=y==-1;
end;

if nargout==0,
  %subplot(121), show(im),
  %subplot(122), show(y),
  im_overlay4(im,y)
  clear y
end;

