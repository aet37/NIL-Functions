function stk=filtStack2(stk,smw,mfn,zff)
% Usage ... stk=filtStack2(stk,smw,mfn,zf)

if nargin<4, zff=[]; end;
if nargin<3, mfn=[]; end;

if isempty(mfn), mfn=0; end;
if isempty(smw), smw=0; end;
if isempty(zff), zff=0; end;

ndim=length(size(stk));
disp(sprintf('  smw= %.2f',smw));
disp(sprintf('  med= %d',mfn));
%disp(sprintf('  zff= %.3f',zff));

if ndim==3,
  if zff>0, 
    tmprng=mean(mean(stk(:,:,1)))/mean(mean(stk(:,:,end)));
    zf=exp(zff*[0:size(stk,3)-1]/size(stk,3))-1; 
    zf=(zf/max(zf))*(tmprng-1)+1; 
  end;
  for mm=1:size(stk,3),
    if mfn>0, stk(:,:,mm)=medfilt2(stk(:,:,mm),[mfn mfn]); end;
    if smw>0, stk(:,:,mm)=im_smooth(stk(:,:,mm),smw); end;
    if zff>0, stk(:,:,mm)=zf(mm)*stk(:,:,mm); end;
  end;
elseif ndim==4,
  for nn=1:size(stk,4),
    if zff>0, 
      tmprng=mean(mean(stk(:,:,1,nn)))/mean(mean(stk(:,:,end,nn)));
      zf=exp(zff*[0:size(stk,3)-1]/size(stk,3))-1; 
      zf=(zf/max(zf))*(tmprng-1)+1; 
    end;
    for mm=1:size(stk,3),
      if mfn>0, stk(:,:,mm,nn)=medfilt2(stk(:,:,mm,nn),[mfn mfn]); end;
      if smw>0, stk(:,:,mm,nn)=im_smooth(stk(:,:,mm,nn),smw); end;
      if zff>0, stk(:,:,mm,nn)=zf(mm)*stk(:,:,mm,nn); end;
    end;
  end;    
elseif ndim==5,
  % need to implement
end;

