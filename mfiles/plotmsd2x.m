function plotmsd2x(x,ymean,ystd,marker)
% Usage ... plotmsd2x(x,ymean,ystd,marker)
% Data must be arranged in row form per trial, since 
% mean and std-dev are take in columns.
% Semilogx equivalent

if ~exist('marker'),
  marker='-';
end;

%[yr,yc]=size(ymatrix);

%ymean=mean;
%ystd=std;
xdelta=x(2)-x(1);


semilogx(x,ymean,'o',x,ymean,marker);
hold on;

for m=1:length(ymean),
  tmplow=ymean(m)-ystd(m);
  tmphi=ymean(m)+ystd(m);
  tmpy=[tmplow tmphi];
  tmpx=[x(m) x(m)];
  if ((marker~='-')|(marker~='--')|(marker~='-.')|(marker~='.')),
    semilogx(tmpx,tmpy,'-');
  else,
    semilogx(tmpx,tmpy,marker);
  end; 
  tmpleft=x(m)-.07*log(x(m));
  tmpright=x(m)+.07*log(x(m));
  tmpx=[tmpleft tmpright];
  tmpy=[tmphi tmphi];
  if ((marker~='-')|(marker~='--')|(marker~='-.')|(marker~='.'))
    semilogx(tmpx,tmpy,'-');
  else,
    semilogx(tmpx,tmpy,marker);
  end; 
  tmpx=[tmpleft tmpright];
  tmpy=[tmplow tmplow];
  if ((marker~='-')|(marker~='--')|(marker~='-.')|(marker~='.'))
    semilogx(tmpx,tmpy,'-');
  else,
    semilogx(tmpx,tmpy,marker);
  end; 
end;

hold off;

