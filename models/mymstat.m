function f=mymstat(imat,tvec,locat)
% Usage ... f=mymstat(imat,locat)
% Calculates the fwhm on the location selected
% Input matrix must have series in columns
% Location is a 2 column [x y] matrix.

[ir,ic]=size(imat);
[tr,tc]=size(tvec);
[lr,lc]=size(locat);

if (ir~=tr),
  error('Error: columns in time vector and matrix do not match!');
end;

go1=1; go2=0;
for n=1:ir,
  if (tvec(n)>=locat(1,1) & go1),
    ind=n; go1=0; go2=1;
  end;
  if (tvec(n)>=locat(2,1) & go2),
    ind(2)=n; go2=0;
  end;
end;

for n=1:ic,
  chunk(:,n)=imat(ind(1):ind(2),n);
end;

[mmax,imax]=max(chunk);

for m=1:ic,
  go1=1; go2=0;
  t1=0; t2=0;
  for n=ind(1):ind(2),
    if ( go1 & (imat(n,m)>=mmax(m)*0.5) ),
      go1=0; t1=tvec(n);
    end;
    if ( n==imax(m)+ind(1) ), go2=1; end;
    if ( go2 & (imat(n,m)<=mmax(m)*0.5) ),
      go2=0; t2=tvec(n);
    end;
  end;
  fwhm(m)=t2-t1;
end;

f=fwhm(:);
