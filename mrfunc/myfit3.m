function out=myfit3(y,taum,breakloc)
%
% Usage ... out=myfit2(y,taum,breakloc)
%
%

x1=1:breakloc(1);
x2=breakloc(1):breakloc(2);
x3=breakloc(2):length(y);
endmean=mean(y(length(y)-4:length(y)));

if ( y(breakloc(1))>=0 ), 
  y1=y(1)*exp(-(x1-1)/taum(1));
else
  y1=(y(1)-y(breakloc(1)))*exp(-(x1-1)/taum(1))+y(breakloc(1));
end;
if ( y(breakloc(2))>=0 ),
  y2=y1(breakloc(1))*exp(-(x2-breakloc(1))/taum(2));
else
  y2=(y1(breakloc(1)-y(breakloc(2))*exp(-(x2-breakloc(1))/taum(2))+y(breakloc(2);
end;
if ( endmean>=0 ),
  y3=y2(breakloc(2))*exp(-(x3-breakloc(2))/taum(3));
else
  y3=(y2(breakloc(2))-endmean)*exp(-(x3-breakloc(2))/taum(3))+endmean;
end;


for n=breakloc(1):breakloc(2),
  y1(n)=y2(n-breakloc(1)+1);
end;
for n=breakloc(2):length(y),
  y1(n)=y3(n-breakloc(2)+1);
end;


out=y1;

