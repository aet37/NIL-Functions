function [m,b]=mreg(xvec,yvec,xzone,lineout)
% Usage ... [m,b]=mreg(xvec,yvec,xzone,lineout)
% Lineout=1 output the line as m
% Lineout=2 output yvec-line as m

xvec=xvec(:);
yvec=yvec(:);

pass1=1;
pass2=0;
pass3=0;
pass4=0;

for m=1:length(xvec),
  if ((xvec(m)>=xzone(1))&pass1),
    pass1=0; pass2=1;
    zvec(1)=m;
  end;
  if ((xvec(m)>=xzone(2))&pass2),
    pass2=0; pass3=1;
    zvec(2)=m;
  end;
  if ((xvec(m)>=xzone(3))&pass3),
    pass3=0; pass4=1;
    zvec(3)=m;
  end;
  if ((xvec(m)>=xzone(4))&pass4),
    pass4=0;
    zvec(4)=m;
  end;
end;

ymean1=mean(yvec(zvec(1):zvec(2)));
ymean2=mean(yvec(zvec(3):zvec(4)));
xmean1=.5*(xzone(1)+xzone(2));
xmean2=.5*(xzone(3)+xzone(4));

m=(ymean2-ymean1)/(xmean2-xmean1);
b=-m*xmean1+ymean1;

if exist('lineout'),
  if (lineout),
    line=m*xvec+b;
    m=line;
  end;
  if (lineout==2),
    m=yvec-line;
  end;
end;

