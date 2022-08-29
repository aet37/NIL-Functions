function yi=myfoh(t,ivar,iyvar,ifix,iyfix,ti)
% usage ... yi=myfoh(t,ivar,iyvar,ifix,iyfix,ti)
%
% Ex. uu=myfoh(t,find((t<0)|(t>4)),0,

y=zeros(size(t));
y(ivar)=iyvar;
y(ifix)=iyfix;
yi=interp1(t,y,ti);
yi(find(isnan(yi)))=0;

if nargout==0,
  plot(t,y,ti,yi)
  fatlines(1.5);
end;
