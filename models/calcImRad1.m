function y=calcImRad1(x,parms,parms2fit,im)
% Usage ... y=calcImRad1(x,parms,pamrs2fit,im)
%
% Ellipse to estimate vessel radius with skewness
% x=[r0 c0 rrad crad ang skew type]

if length(im)==2,
  y=zeros(im);
else,
  y=zeros(size(im));
end;

if ~isempty(parms2fit), parms(parms2fit)=x; end;
if length(parms)==7, ctype=2; else, ctype=1; parms(7)=1; end;

r0=parms(1);
c0=parms(2);
rw=parms(3);
cw=parms(4);
ang=parms(5);
skw=parms(6);
cf=parms(7);

if c0<2, c0=2; end;
if c0>(size(y,1)-1), c0=size(y,1)-1; end;
if r0<2, r0=2; end;
if r0>(size(y,2)-1), r0=size(y,2)-1; end;

[rr,cc]=meshgrid([1:size(y,1)]-r0,[1:size(y,2)]-c0);
if abs(ang)>100*eps,
  ang=ang*(pi/180);
  tmprc=[rr(:) cc(:)]*[cos(ang) -sin(ang); sin(ang) cos(ang)];
  rr=reshape(tmprc(:,1),size(rr));
  cc=reshape(tmprc(:,2),size(cc));
end;

if ctype==2,
  cc=cc*cf;
  rc=sqrt( rr.^2 + cc.^2 );
  y=1./(1+exp((rc-rw)/cw));
  if abs(skw)>100*eps,
    rr=rr-skw;
    rc=sqrt( rr.^2 + cc.^2 );
    y=1./(1+exp((rc-rw)/cw));
    y=y.*(1+sk);
  end;
else,
  y=exp( -((rr/rw).^2 + (cc/cw).^2) );
  if abs(skw)>100*eps,
    skw
    sk=exp( -(((rr-skw)/rw).^2 + ((cc-skw)/cw).^2) );
    %clf, subplot(121), show(y), subplot(122), show(sk), drawnow,
    y=y.*(sk+1);
  end;
end;

if nargout==0,
  clf,
  if length(im)==2,
    subplot(121), show(y),
    subplot(122), plot([y(r0,:)' y(:,c0)]),
  else,
    subplot(221), show(y),
    subplot(222), plot([y(r0,:)' y(:,c0)]),
    subplot(221), show(im_super(im,y,0.4)),
    subplot(222), plot([im(r0,:)' im(:,c0)]),
  end;
  clear y
end;

