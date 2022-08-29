function out=myfit2(y,taum,breakloc)
%
% Usage ... out=myfit2(y,taum,breakloc)
%
%

x1=1:breakloc;
x2=breakloc:length(y);
endmean=mean(y(length(y)-4:length(y)));

if ( y(breakloc)>=0 ), 
  y1=y(1)*exp(-(x1-1)/taum(1));
else
  y1=(y(1)-y(breakloc))*exp(-(x1-1)/taum(1))+y(breakloc);
end;
if ( endmean>=0 ),
  y2=y1(breakloc)*exp(-(x2-breakloc)/taum(2));
else
  y2=(y1(breakloc)-endmean)*exp(-(x2-breakloc)/taum(2))+endmean;
end;

for n=breakloc:length(y),
  y1(n)=y2(n-breakloc+1);
end;

out=y1;

