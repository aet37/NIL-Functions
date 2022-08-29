clear

circ=1;

step=[-1 -0.5 0 0.5 1];
nleaves=length(step)-1;
inv=-1; 

for n=1:nleaves,
  x=[step(n):.025:step(n+1)];
  y=ones(1,21);
  for m=1:20, 
    inv=-1*inv;
    if inv==1, start=step(n+1); else, start=step(n); end;
    tmpx=zeros(1,21); tmpx(1)=start; for o=2:21, tmpx(o)=tmpx(o-1)+inv*(-1)*0.025; end; 
    y=[y (1-0.025*nleaves*m)*ones(1,21)];
    x=[x tmpx];
  end;
  ky(:,n)=y';
  kx(:,n)=x';
  clear x y
end; 

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
plot(ckx1,cky1,ckx2,cky2,ckx3,cky3,ckx4,cky4)
else,
plot(kx(:,1),ky(:,1),kx(:,2),ky(:,2),kx(:,3),ky(:,3),kx(:,4),ky(:,4)) 
end;

