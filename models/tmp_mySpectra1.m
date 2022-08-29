function yy=tmp_mySpectra1(xx,x0,w0)
% Usage ... y=tmp_mySpectra1(xx,x0,w0)
%
% Ex. mySpectra1([350:700],[488 515],[4 14])
%
if length(xx)==2, xx=[x(1):x(2)]; end;
xx=xx(:);

%xx=[350:700];
%x0=[488 515];
%w0=[4 14];

w1=w0(1);
x1=x0(1)+3*w1;
w2=w0(2);
x2=x0(1)-3*w2;

w3=w0(2);
x3=x0(2)+3*w3;
w4=w0(1);
x4=x0(2)-3*w4;

y1=1./(1+exp((xx-x1)/w1)) -1./(1+exp((xx-x2)/w2));
y3=1./(1+exp((xx-x3)/w3)) -1./(1+exp((xx-x4)/w4));

yy=[y1(:) y3(:)];

if nargout==0,
  figure(1), clf,
  plot(xx,[y1 y3]), axis tight, grid on, fatlines(1.5);
  drawnow,
end
