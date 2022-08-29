function plotmsd(x,ymean,ystd,marker1,marker2,mcolor)
% Usage ... plotmsd(x,ymean,ystd,marker1,marker2,mcolor)
% 
% ymean and ystd plotting entries are assumed to be organized in rows
% marker1 is the marker for the line connecting the means
% marker2 is the marker for the mean points
% mcolor is the color of each line and markers

if ~exist('marker1'),
  marker1=;
end;
if ~exist('marker2'),
  marker2=;
end;
if ~exist('mcolor'),
  mcolor=;
end;

%[yr,yc]=size(ymatrix);

%ymean=mean;
%ystd=std;
xdelta=x(2)-x(1);


for n=1:size(ymean,1),
  % draw line and marker on mean point
  plot(x,ymean(n,:),sprintf('%s%s%s',marker1{n},marker2{n},mcolor{n}))
  if (n==1)&(m==1), hold('on'); end;
  for m=1:size(ymean,2),
    % draw vertical line for 1 std
    tmplow=ymean(n,m)-ystd(n,m);
    tmphi=ymean(n,m)+ystd(n,m);
    tmpy=[tmplow tmphi];
    tmpx=[x(m) x(m)];
    plot(tmpx,tmpy,sprintf('%s%s',marker1{n},mcolor{n}))
    % draw the little horizontal lines at top and bottom
    tmpleft=x(m)-.07*xdelta;
    tmpright=x(m)+.07*xdelta;
    tmpx=[tmpleft tmpright];
    tmpy=[tmphi tmphi];
    plot(tmpx,tmpy,sprintf('%s%s',marker1{n},mcolor{n}))
    tmpx=[tmpleft tmpright];
    tmpy=[tmplow tmplow];
    plot(tmpx,tmpy,sprintf('%s%s',marker1{n},mcolor{n}))
  end;
end;
hold('off');

