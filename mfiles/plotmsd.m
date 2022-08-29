function plotmsd(x,ymatrix,taxis,fig)
% Usage ... plotmsd(x,ymatrix,taxis,fig)
% Data must be arranged in row form per trial, since 
% mean and std-dev are take in columns.

if exist('fig'),
  hold on
  figure(fig);
  marker=taxis;
else,
  marker='-';
end;

[yr,yc]=size(ymatrix);

ymean=mean(ymatrix);
ystd=std(ymatrix);
xdelta=x(2)-x(1);

plot(x,ymean,'o',x,ymean,marker);
hold on;

for m=1:yc,
  tmplow=ymean(m)-ystd(m);
  tmphi=ymean(m)+ystd(m);
  tmpy=[tmplow tmphi];
  tmpx=[x(m) x(m)];
  plot(tmpx,tmpy,marker);
  tmpleft=x(m)-.1*xdelta;
  tmpright=x(m)+.1*xdelta;
  tmpx=[tmpleft tmpright];
  tmpy=[tmphi tmphi];
  plot(tmpx,tmpy,marker);
  tmpx=[tmpleft tmpright];
  tmpy=[tmplow tmplow];
  plot(tmpx,tmpy,marker);
end;

hold off;

