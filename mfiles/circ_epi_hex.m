clear

circ=1; part=1; ss=0;

nleaves=4;
for n=1:nleaves, step(n)=1-(n-1)*0.1*sqrt(3)-.051; end;

for n=1:nleaves,
  if (rem(n,2)), x=[-1.2:.2:1.2]; else, x=[-1.1:.2:1.3]; end;
  y=step(n)*ones(1,13);
  inv=-1;
  for m=1:4, 
    inv=-1*inv;
    if inv==-1,
      if (rem(n,2)), tmpx=[-1.2:.2:1.2]; else, tmpx=[-1.1:.2:1.3]; end;
    else,
      if (rem(n,2)), tmpx=zeros(1,13); tmpx(1)=1.2; for o=2:13, tmpx(o)=tmpx(o-1)-0.2; end;
      else, tmpx=zeros(1,13); tmpx(1)=1.3; for o=2:13, tmpx(o)=tmpx(o-1)-0.2; end;
      end;
    end; 
    y=[y (step(n)-0.1*sqrt(3)*nleaves*m)*ones(1,13)];
    x=[x tmpx];
  end;
  ky(:,n)=y';
  kx(:,n)=x';
  clear x y
  %plot(kx,ky,'o',kx,ky,'-'), pause,
end; 

if (circ),
for n=1:size(ky,2),
  cnt=0;
  for m=1:size(ky,1),
    if (kx(m,n)*kx(m,n)+ky(m,n)*ky(m,n))<=1.1,
      cnt=cnt+1;
      eval(['ckx',int2str(n),'(cnt)=kx(m,n);']);
      eval(['cky',int2str(n),'(cnt)=ky(m,n);']);
    end;
  end;
end;
plot(ckx1,cky1,'yx',ckx2,cky2,'mo',ckx3,cky3,'co',ckx4,cky4,'ro',ckx1,cky1,'y-',ckx2,cky2,'m:',ckx3,cky3,'c:',ckx4,cky4,'r:'),
else,
plot(kx(:,1),ky(:,1),kx(:,2),ky(:,2),kx(:,3),ky(:,3),kx(:,4),ky(:,4)) 
end;
pause,

if (part),
for n=1:nleaves,
  cnt=0;
  eval(['newlen=length(cky',int2str(n),');']);
  for m=1:newlen,
    tmpcmd=['if ckx',int2str(n),'(m)<=0.21,'];
    tmpcmd=[tmpcmd,'cnt=cnt+1;'];
    tmpcmd=[tmpcmd,'pkx',int2str(n),'(cnt)=ckx',int2str(n),'(m);'];
    tmpcmd=[tmpcmd,'pky',int2str(n),'(cnt)=cky',int2str(n),'(m);'];
    tmpcmd=[tmpcmd,'end;'];
    eval(tmpcmd);
  end;
end;
plot(pkx1,pky1,'yx',pkx2,pky2,'mo',pkx3,pky3,'co',pkx4,pky4,'ro',pkx1,pky1,'y-',pkx2,pky2,'m:',pkx3,pky3,'c:',pkx4,pky4,'r:'),
end;

if (ss),
  clear tmpx tmpy sskx ssky;
  sskx=ckx1(1:5); ssky=cky1(1:5);
  for m=1:8, tmpx(m)=ckx2(9-m); tmpy(m)=cky2(9-m); end;
  sskx=[sskx tmpx ckx3(1:9)]; ssky=[ssky tmpy cky3(1:9)]; clear tmpx tmpy;
  for m=1:10, tmpx(m)=ckx4(11-m); tmpy(m)=cky4(11-m); end; 
  sskx=[sskx tmpx]; ssky=[ssky tmpy]; clear tmpx tmpy;
  for m=6:16, tmpx(m-5)=ckx1(22-m); tmpy(m-5)=cky1(22-m); end;
  sskx=[sskx tmpx ckx2(9:18)]; ssky=[ssky tmpy cky2(9:18)]; clear tmpx tmpy
  for m=10:20, tmpx(m-9)=ckx3(30-m); tmpy(m-9)=cky3(30-m); end;
  sskx=[sskx tmpx ckx4(11:20) ckx1(17:25)]; ssky=[ssky tmpy cky4(11:20) cky1(17:25)]; clear tmpx tmpy;
  for m=19:26, tmpx(m-18)=ckx2(45-m); tmpy(m-18)=cky2(45-m); end;
  sskx=[sskx tmpx ckx3(21:27)]; ssky=[ssky tmpy cky3(21:27)]; clear tmpx tmpy
  for m=21:24, tmpx(m-20)=ckx4(45-m); tmpy(m-20)=cky4(45-m); end;
  sskx=[sskx tmpx]; ssky=[ssky tmpy];
  plot(sskx,ssky,'y-',sskx,ssky,'yx'),
end;

