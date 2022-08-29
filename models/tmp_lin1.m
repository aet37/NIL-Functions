function yfit=tmp_lin1(x0,u,h,y)
% Usage ... yfit=tmp_lin1(x,u,h,y)

xopt=optimset('fminsearch');

xx = fminsearch(@tmp_lin1_here, x0, xopt, u, h, y);
y0 = tmp_lin1_here( x0, u, h );
yfit = tmp_lin1_here( xx, u, h );

if nargout==0,
    clf,
    plot([y(:) y0(:) yfit(:)]);
    axis tight, grid on,
    xx,
end

return,


%% function definitions
%

function [ee,yfit]=tmp_lin1_here(x,u,h,y)

yfit = zeros(size(u,1),1);
for mm=1:size(u,2),
  yfit = yfit + x(mm)*myconv( u(:,mm), h(:,mm) );
end;

if nargin<4,
  ee=yfit;
else,
  ee = mean((y - yfit).^2);
  %ee = corr(y,yfit);
  disp(sprintf('  %.6f',ee));
end


return

