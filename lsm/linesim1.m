
ll=[4 1];
ls=[5 2];

a=zeros(400,400);
deg=21.1;

ww=0;
tmpfound=0;
while(~tmpfound),
  tmps=round(ls.*randn(size(ls)));
  tmpsp=abs(tmps(1))+tmps(2);
  tmpw=round(ll.*randn(size(ll)));
  tmpws=abs(tmpw(1))+tmpw(2);
  if tmpsp<1, tmpsp=1; end;
  if tmpws<1, tmpws=1; end;
  ww=ww+tmpsp;
  if ww+tmpws>400,
    a([ww:400],:)=1;
  else,
    a(ww+[0:tmpws],:)=1;
  end;
  ww=ww+tmpws;
  if ww>400, tmpfound=1; end;
end;

as=a+im_smooth(a,1)+0.2*randn(size(a));
ar=imrotate(abs(as),deg,'bicubic','crop');
%ar=rot2d_f(abs(as),deg);
aa=abs(ar(101:300,101:300));

clear tmp*

