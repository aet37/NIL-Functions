function [ym,tm,ymi]=getTCmax(y,t,tlim,tspan)
% Usage ... m=getTCmax(y,t,tlim,tspan)

if nargin<4, tspan=-1; end;
if isempty(t), t=[1:length(y)]; t=t(:); end;
if isempty(tlim), tlim=[t(1) t(end)]; end;

ii=find((t>=tlim(1))&(t<=tlim(2)));

if tspan<0, 
  [z,zi]=max(y); 
  tz=t(zi);
else,
  is=round(tspan/diff(t(1:2)));
  iis=[0:is-1]-ceil(is/2);
  if prod(size(y))==length(y), y=y(:); end;
  for mm=1:size(y,2),
    tmptc=y(:,mm);
    tmptt=t(ii);
    [tmpmax,tmpmaxi]=max(tmptc(ii));
    if t(ii(1)-1+tmpmaxi)<(tlim(1)+tspan/2),
      ym(mm)=mean(tmptc(ii(1)+[0:is-1]));
      tm(mm)=mean(t(ii(1)+[0:is-1]));
      ymi(mm)=ii(1)+round(is/2);
    elseif t(ii(1)-1+tmpmaxi)>(tlim(2)-tspan/2),
      ym(mm)=mean(tmptc(ii(end)-[0:is-1]));
      tm(mm)=mean(t(ii(end)-[0:is-1]));
      ymi(mm)=ii(end)-round(is/2);
    else,
      ym(mm)=mean(tmptc(tmpmaxi+ii(1)-1+iis));
      tm(mm)=tmptt(tmpmaxi);
      ymi(mm)=tmpmaxi+ii(1)-1;
    end;
    if nargout==0,
      disp(sprintf(' %d: max= %.3f  t= %.3f',mm,ym(mm),tm(mm)));
      plot(t,tmptc,t(ii([1 end])),tmptc(ii([1 end])),'bo',tm(mm),ym(mm),'ko',tmptt(tmpmaxi),tmpmax,'kx'),
      xlabel(num2str(mm)), drawnow, pause(1),
    end;
    %keyboard,
  end;
end;

