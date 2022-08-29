
ii1=4;
ii2=5;

tmpim1=data(:,:,ii1);
tmpim2=data(:,:,ii2);

aa=simple_piv(tmpim1,tmpim2,[1 3]);

tmpxc=ifft2(fft2(tmpim1).*fft2(tmpim2(end:-1:1,end:-1:1)));
[maxi,maxj]=find(tmpxc>0.999*max(max(tmpxc)));

for mm=2:nfr,
  dd(mm)=simple_piv(data(:,:,mm-1),data(:,:,mm),[1 3 0]);
  dd2(mm)=simple_piv(data(:,:,mm-1),data(:,:,mm),[1 3 1]);
end;

