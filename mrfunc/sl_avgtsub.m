function y=sl_avgtsub(slpath,slno,bref,imsize,norm)
% Usage ... y=sl_avgtsub(slpath,slno,bref,imsize,norm)

if nargin<5, norm=0; end;

a1=0;
a2=0;
cnt1=0;
cnt2=0;
for m=1:length(bref),
  if (bref(m)==1),
    cnt1=cnt1+1;
    a1=a1+getslim(slpath,slno,m,imsize);
  else,
    cnt2=cnt2+1;
    a2=a2+getslim(slpath,slno,m,imsize);
  end;
end;
y=(1/cnt1)*a1-(1/cnt2)*a2;
if (norm),
  for m=1:imsize(1), for n=1:imsize(2),
    if (a1(m,n)~=0),
      y(m,n)=cnt1*y(m,n)./a1(m,n); 
    else,
      y(m,n)=0;
    end;
  end; end;
end;

