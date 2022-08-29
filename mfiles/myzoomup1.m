function [im1,f2]=myzoomup1(im,size1)
% Usage ... im1=myzoomup1(im,size1)

[rr,cc]=size(im);

fourier=1;

if (fourier),

  rm=floor(rr/2);
  cm=floor(cc/2);

  if (rr>size1(1))|(cc>size1(2)),
    error('Only up sizes are allowed');
  end;

  f1=fft(im);
  f2=zeros(size1);
  f2(1:rm,1:cm)=f1(1:rm,1:cm);
  f2(size1(1)-rm+1:size1(1),size1(2)-cm+1:size1(2))=f1(rm+1:rr,cm+1:cc);
  im1=abs(ifft2(f2));

else,

  f2=zeros(size1);
  ii=[0:rr/size1(1):rr-rr/size1(1)]; %size(ii),
  for m=1:rr, a(m,:)=interp1([0:rr-1],im(m,:),ii); end;
  ii=[0:cc/size1(2):cc-cc/size1(2)]; %size(ii),
  for m=1:size1(2), im1(:,m)=interp1([0:cc-1],a(:,m),ii).'; end;

end;
