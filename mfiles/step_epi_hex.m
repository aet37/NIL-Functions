clear

circ=1;
step=[-.9 -.45 0 .45 .9];
nleaves=length(step)-1;

for n=1:nleaves,
  x=[step(n):.15:step(n+1)];
  y=ones(1,4);
  inv=-1;
  for m=1:30, 
    inv=-1*inv;
    if inv==-1, start=step(n); else, start=step(n+1)-0.075; end;
    tmpx=zeros(1,4); tmpx(1)=start; for o=2:4, tmpx(o)=tmpx(o-1)+inv*(-1)*0.15; end; 
    y=[y (1-0.075*sqrt(3)*m)*ones(1,4)];
    x=[x tmpx];
  end;
  ky(:,n)=y';
  kx(:,n)=x';
  plot(kx,ky), pause,
  clear x y
end; 
ky=ky+0.2*sqrt(3);

if (circ),
for n=1:size(ky,2),
  cnt=0;
  for m=1:size(ky,1),
    if (kx(m,n)*kx(m,n)+ky(m,n)*ky(m,n))<=1,
      cnt=cnt+1;
      eval(['ckx',int2str(n),'(cnt)=kx(m,n);']);
      eval(['cky',int2str(n),'(cnt)=ky(m,n);']);
    end;
  end;
end;
plot(ckx1,cky1,'yx',ckx2,cky2,'mo',ckx3,cky3,'co',ckx4,cky4,'ro',ckx1,cky1,'y-',ckx2,cky2,'m:',ckx3,cky3,'c:',ckx4,cky4,'r:')
else,
plot(kx(:,1),ky(:,1),kx(:,2),ky(:,2),kx(:,3),ky(:,3),kx(:,4),ky(:,4)) 
end;

