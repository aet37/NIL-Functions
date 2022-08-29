function plotmsd(x,ymean,ystd,marker)
% Usage ... plotmsd(x,ymean,ystd,marker)
% Data must be arranged in row form per trial, since 
% mean and std-dev are take in columns.

if ~exist('marker'),
  marker='b-';
end;

%[yr,yc]=size(ymatrix);

%ymean=mean;
%ystd=std;
xdelta=x(2)-x(1);


plot(x,ymean,[marker,'o']);
hold on;

for mm=1:size(ymean,1), for nn=1:size(ymean,2), 
  tmplow=ymean(mm,nn)-ystd(mm,nn);
  tmphi=ymean(mm,nn)+ystd(mm,nn);
  tmpy=[tmplow tmphi];
  tmpx=[x(mm) x(mm)];
  %if ((marker~='-')|(marker~='--')|(marker~='-.')|(marker~='.')),
  %  plot(tmpx,tmpy,'-');
  %else,
    plot(tmpx,tmpy,marker);
  %end; 
  tmpleft=x(mm)-.07*xdelta;
  tmpright=x(mm)+.07*xdelta;
  tmpx=[tmpleft tmpright];
  tmpy=[tmphi tmphi];
  %if ((marker~='-')|(marker~='--')|(marker~='-.')|(marker~='.'))
  %  plot(tmpx,tmpy,'-');
  %else,
    plot(tmpx,tmpy,marker);
  %end; 
  tmpx=[tmpleft tmpright];
  tmpy=[tmplow tmplow];
  %if ((marker~='-')|(marker~='--')|(marker~='-.')|(marker~='.'))
  %  plot(tmpx,tmpy,'-');
  %else,
    plot(tmpx,tmpy,marker);
  %end; 
end; end;

hold off;

