function mdat=myreshapestk(stk,mask)
% Usage ... mdat=myreshapestk(stk,mask)

maskdim=size(mask);
maski=find(mask);
stkdim=size(stk);
if length(stkdim)==2,
  mdat=zeros(maskdim(1),maskdim(2),stkdim(2));
  for mm=1:stkdim(2),
    tmpim=zeros(maskdim);
    tmpim(maski)=stk(:,mm);
    mdat(:,:,mm)=tmpim;
  end;
else,
  mdat=zeros(length(maski),stkdim(3));
  for mm=1:stkdim(3),
    tmpim=stk(:,:,mm);
    mdat(:,mm)=tmpim(maski);
  end;
end;

