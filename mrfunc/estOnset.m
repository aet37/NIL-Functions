function ot=estOnset(y,t,bii,type)
% Usage ... ot=estOnset(y,t,bii,type)

if nargin<4,
  type=1;
end;
if nargin<3,
  bii=[];
end;

if nargin<2,
  t=[1:length(y)];
end;
if (size(y,1)==1), y=y(:); end;

for mm=1:size(y,2),
  yy=y(:,mm);
  if (~isempty(bii)), yy=yy/mean(yy(bii))-1; end;
  [ymax,ymaxi]=max(yy);
  [ymin,ymini]=min(yy);
  if (abs(ymin)>abs(ymax)), yy=-yy; ymax=-ymin; ymaxi=ymini; end;
  if (type==2),		% time to 2.5x stdev over baseline
    ystd=std(yy(bii)); 
    stdi=find(yy>=2.5*ystd);
    ot(mm)=t(stdi(1));
  elseif (type==3),	% time-to-half-max
    ti=[t(1):0.1*(t(2)-t(1)):t(end)];
    yyi=interp1(t,yy,ti);
    i50=find(yyi>0.5*ymax);
    ot(mm)=ti(i50(1));
  else,			% intercept to zero from time-to-half-max
    i50=find(yy>0.5*ymax);
    in=i50(1)+[-1:1];
    n50=polyfit(t(in),yy(in),1);
    ot(mm)=-n50(2)/n50(1);
    tl=t([1:2*i50(1)]);
    yyl=polyval(n50,tl);
  end;
end;

if (nargout==0),
  if (type==1),
    plot(t,yy,tl,yyl,t(in),yy(in),'o')
    grid('on')
    title(sprintf('Onset time %f',ot))
  elseif (type==2),
    plot(t,y,ot,y(stdi(1)),'o')
    grid('on')
    title(sprintf('Onset time %f (%f)',ot,ystd))
  elseif (type==3),
    plot(ti,yyi,ti(i50(1)),yyi(i50(1)),'o')
    %plot(t,y,ot(1),yyi(i50(1)),'o')
    grid('on')
    title(sprintf('Onset time %f',ot))
  end;
end;

