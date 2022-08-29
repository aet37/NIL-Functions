clear

circ=1;

x=[-1:.2:1];
inv=-1;
y=ones(1,11);
for m=1:30, 
  inv=-1*inv;
  if inv==1, start=1-0.1; else, start=-1; end;
  tmpx=zeros(1,11); tmpx(1)=start; for o=2:11, tmpx(o)=tmpx(o-1)+inv*(-1)*0.2; end; 
  y=[y (1-0.1*sqrt(3)*m)*ones(1,11)];
  x=[x tmpx];
end;
ky=y';
kx=x';
plot(kx,ky,'*'), pause,
clear x y
end; 
kx=kx;
ky=ky+0.165*sqrt(3);

if (circ),
  cnt=0;
  for m=1:length(ky),
    if (kx(m)*kx(m)+ky(m)*ky(m))<=.95,
      cnt=cnt+1;
      ckx(cnt)=kx(m);
      cky(cnt)=ky(m);
    end;
  end;
  plot(ckx,cky,'y-',ckx,cky,'yx'),
else,
  plot(kx,ky),
end;

