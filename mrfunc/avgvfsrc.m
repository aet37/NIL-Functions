function out=avgvfsrc(mask,sourcemap,range)
%
% Usage ... out=avgvfsrc(mask,sourcemap,range)
%
%

figure(1);
clg;
show(mask);
axis('on');
xlabel('Press return when done');

pixloc=round(ginput);

for n=1:length(pixloc),
  tmpsum=0;
  tmp=0;
  for m=1:fix(range),
  tmpsum=tmpsum+sourcemap(pixloc(n,1),pixloc(n,2));
  tmpsum=tmpsum+sourcemap(pixloc(n,1)+m,pixloc(n,2));
  tmpsum=tmpsum+sourcemap(pixloc(n,1)-m,pixloc(n,2));
  tmpsum=tmpsum+sourcemap(pixloc(n,1),pixloc(n,2)+m);
  tmpsum=tmpsum+sourcemap(pixloc(n,1),pixloc(n,2)-m);
  tmp=tmp+5;
  if ( 2*rem(range,fix(range)) ),
    tmpsum=tmpsum+sourcemap(pixloc(n,1)+m,pixloc(n,2)+m);
    tmpsum=tmpsum+sourcemap(pixloc(n,1)-m,pixloc(n,2)-m);
    tmpsum=tmpsum+sourcemap(pixloc(n,1)+m,pixloc(n,2)-m);
    tmpsum=tmpsum+sourcemap(pixloc(n,1)-m,pixloc(n,2)+m);
    tmp=tmp+4;
  end;
  end;
  tmpavg(n)=tmpsum/tmp;
end;

out=tmpavg;
