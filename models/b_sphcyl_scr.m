
clear all

dim=[-1:.02:+1].';
dim0=zeros(size(dim));

Cr=0.2;
Cang=[pi/2 0];	% recall, x-y angle matters geometrically but NOT magnetically
dX=2e-7;
B0v=[0 0 94000];


%cnt=1; for mm=1:length(dim), for nn=1:length(dim),
%  x2(cnt)=dim(mm); y2(cnt)=dim(nn);
%  cnt=cnt+1;
%end; end;
%x2=x2(:); y2=y2(:); z2=zeros(size(x2));
%
%disp(sprintf('Calculating field for cylinder (%d elements)...',cnt-1));
%bc=b_cyl([x2 y2 z2],B0v,Cr,Cang,1+dX,1);
%disp('Done...')
%
%mesh(x2,y2,z2,bc)

bc(:,1)=b_cyl([dim  dim0 dim0],B0v,Cr,Cang,1+dX,1);
bc(:,2)=b_cyl([dim0 dim  dim0],B0v,Cr,Cang,1+dX,1);
bc(:,3)=b_cyl([dim0 dim0 dim ],B0v,Cr,Cang,1+dX,1);
bc(:,4)=b_cyl([dim  dim  dim0],B0v,Cr,Cang,1+dX,1);

bs(:,1)=b_sph([dim  dim0 dim0],B0v,Cr,1+dX,1);
bs(:,2)=b_sph([dim0 dim  dim0],B0v,Cr,1+dX,1);
bs(:,3)=b_sph([dim0 dim0 dim ],B0v,Cr,1+dX,1);
bs(:,4)=b_sph([dim  dim  dim0],B0v,Cr,1+dX,1);

subplot(211)
plot(dim,bc)
ylabel('B Field'),
title('Cylinder'),
grid('on'); axis('tight'); fatlines; 
legend('x','y','z','xy')
subplot(212)
plot(dim,bs)
ylabel('B Field'),
title('Sphere')
grid('on'); axis('tight'); fatlines; 
legend('x','y','z','xy')


