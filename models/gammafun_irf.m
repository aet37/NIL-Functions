function e=gammafun_irf(x,t,u,parms,parms2fit,y)
% Usage ... e=gammafun_irf(x,t,u,parms,parms2fit,y)
%
% parms=[g1 g2 g3-amp t0 baseline]

verbose_flag=1;
if nargin<5, parms2fit=[]; end;
if ~isempty(parms2fit), parms(parms2fit)=x; end;

g=gammafun2(t,t(1)+parms(4),parms(1),parms(2),1.0);
if length(parms)>5,
  g=g-parms(8)*gammafun2(t,t(1)+parms(4),parms(1)+parms(6),parms(7),1.0);
end;
g=parms(3)*g;
%plot(g), pause,
z=myconv(u,g)+parms(5);

if nargin<6,
  e=z;
else,
  e=z(:)-y(:);
  if verbose_flag,
    disp(sprintf('  g1=%.3e g2=%.3e g3=%.3e g4=%.3e g5=%.3e ee=%.4f',...
         parms(1),parms(2),parms(3),parms(4),parms(5),sum(e.^2)));
    plot([z(:) y(:)]), drawnow,
  end;
end;

if nargout==0, clf, plot(t,u,t,y,t,z), end;


