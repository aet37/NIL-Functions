function [y,ymax,ymaxi]=getRadProj1(data,rads,ptype)
% Usage ... y=getRadProj1(data,rad_struct,ptype)
%
% ptype=[0:projections are returned, 1:max-maxi returned/default[

if nargin<3, ptype=1; end;

data=squeeze(data);

for mm=1:size(data,3),
  tmpim=data(:,:,mm);
  for nn=1:length(rads),
    [tmpp]=getRectImGrid(tmpim,rads(nn));
    tmpp=mean(tmpp,2);
    yp{nn}(:,mm)=tmpp;
    [tmpmax,tmpmaxi]=max(tmpp);
    ymax(mm,nn)=tmpmax;
    ymaxi(mm,nn)=tmpmaxi;    
  end;
end;

if ptype==1,
  y.max=ymax;
  y.maxi=ymaxi;
else,
  y=yp;
end;
