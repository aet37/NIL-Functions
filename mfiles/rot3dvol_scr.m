
dd=size(a);
ss=[567 567 520];

xx=[1:dd(1)];
yy=[1:dd(2)];
zz=[1:dd(3)];
cc=round(dd/2)+1;

xxi=[0:ss(1)-1]*(dd(1)-1)/(ss(1)-1)+1;
yyi=[0:ss(2)-1]*(dd(2)-1)/(ss(2)-1)+1;
zzi=[0:ss(3)-1]*(dd(3)-1)/(ss(3)-1)+1;

[xxx,yyy,zzz]=meshgrid(xx,yy,zz);
[xxxi,yyyi,zzzi]=meshgrid(xxi,yyi,zzi);

rotangles=[0 0 0];

tmp=rot3d([xxxi(:) yyyi(:) zzzi(:)],rotangles);
xxxir=reshape(tmp(:,1),size(xxxi));
yyyir=reshape(tmp(:,2),size(yyyi));
zzzir=reshape(tmp(:,3),size(zzzi));

aiii=interp3(xxx,yyy,zzz,a,xxxir,yyyir,zzzir);

