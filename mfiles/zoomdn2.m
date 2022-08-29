function [y2,y]=zoomdn2(x)

ds_type=2;
imsize=size(x);


if (ds_type==2),
  y(:,:,1)=x(1:2:end,1:2:end);
  y(:,:,2)=x(1:2:end,2:2:end);
  y(:,:,3)=x(2:2:end,1:2:end);
  y(:,:,4)=x(2:2:end,2:2:end);
  y2=mean(y,3);
else,
  disp(' zooming down dim 1...');
  for m=1:imsize(1), 
    cnt1=0;
    for n=1:2:imsize(2),
      cnt1=cnt1+1;
      y(m,cnt1)=x(m,n)+x(m,n+1);
    end;
  end; 
  disp(' zooming down dim 2...');
  cnt2=0;
  for m=1:2:imsize(1), 
    cnt2=cnt2+1;
    for n=1:cnt1,
      y2(cnt2,n)=y(m,n)+y(m+1,n);
    end;
  end;
  y2=y2/4;
end;


