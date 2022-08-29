function [y,yi]=tc_outlier_rm(x,ww,dthr)
% Usage ... y=tc_outlier_rm(x,ww,dthr)
%
% Removes outliers from time series x based on a running window 
% of width ww samples and threshold difference from window mean
% of dthr


rep_type=2;

do_std=0;
if nargin<3,
  do_std=1;
end;

xlen=length(x);
yi=zeros(size(x));

if do_std,
  dthr=std(x);
  disp(sprintf('  using dthr= %f',dthr));
end;

cnt=0;
for mm=1:xlen,
  i1=mm-ceil(ww/2);
  i2=mm+floor(ww/2);
  if (i1<1), i1=1; end;
  if (i2>xlen), i2=xlen; end;
  wavg=mean(x(i1:i2));
  %wstd=std(x(i1:i2));
  if abs(x(mm)-wavg)>dthr,
    if rep_type==2,
      tmpx=x(i1:i2);
      tmpii=find(abs(tmpx-wavg)<=dthr);  
      y(mm)=mean(tmpx(tmpii));
    else,
      y(mm)=wavg;
    end;   
    yi(mm)=1;
    cnt=cnt+1;
  else,
    y(mm)=x(mm);
  end;
end;

if nargout==0,
  plot([x(:) y(:)])
  title(sprintf('# outliers removed = %d',cnt));
end;


