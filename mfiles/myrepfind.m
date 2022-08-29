function [ii,is]=myrepfind(tt,range,rept)
% Usage ... ii=myrepfind(tt,range,rept)

ii=[];
for mm=1:length(rept),
  tmpt1=rept(mm)+range(1);
  tmpt2=rept(mm)+range(2);
  %disp(sprintf('  %d: %f to %f',mm,tmpt1,tmpt2));
  tmpi=find((tt>=tmpt1)&(tt<tmpt2));
  in(mm)=length(tmpi);
  ic{mm}=tmpi;
  if length(tmpi)>0,
    ii=[ii;tmpi(:)];
    ir(mm,:)=[tmpt1 tmpt2];
  end;
end;

if nargout==2,
  is.ii=ic;
  is.in=in;
  is.ir=ir;
end;

