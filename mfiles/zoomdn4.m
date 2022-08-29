function [y2,y]=zoomdn4(x)

imsize=size(x);

disp(' zooming down dim 1...');
for m=1:imsize(1), 
  cnt1=0;
  for n=1:4:imsize(2),
    cnt1=cnt1+1;
    y(m,cnt1)=x(m,n)+x(m,n+1)+x(m,n+2)+x(m,n+3);
  end;
end; 
disp(' zooming down dim 2...');
cnt2=0;
for m=1:4:imsize(1), 
  cnt2=cnt2+1;
  for n=1:cnt1,
    y2(cnt2,n)=y(m,n)+y(m+1,n)+y(m+2,n)+y(m+3,n);
  end;
end;
y2=y2/16;

