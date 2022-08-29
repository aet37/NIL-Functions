function xx=multiHRF1_scr(hrfs,uu,x0,data)
% Usage x=multiHRF1_scr(hrfs,uu,x0,data)
%

y0=multiHRF1_here(x0,hrfs,uu);

if nargout==0,
  clf,
  plot([data(:) y0(:)])
  axis('tight'), grid('on'), fatlines(1.5),
  %tmpax=axis; axis([tbias tmpax(3:4)]);
  disp('  press enter to continue...')
  pause,
end;

xopt=optimset('fminsearch');
xopt.TolX=1e-8;

xx1=fminsearch(@multiHRF1_here,x0,xopt,hrfs,uu,data);
%xx2=fminsearch(@multiHRF1_here,x0,xopt,hrfs,uu,data);
%xx0=fminsearch(@multiHRF1_here,x0,xopt,hrfs,uu,data);

[y1]=multiHRF1_here(xx1,hrfs,uu);
%[y2]=multiHRF1_here(xx2,hrfs,uu);
%[y0]=multiHRF1_here(xx0,hrfs,uu);

rr1=corr(data,y1);
%rr2=corr(data,y2);
%rr0=corr(data,y0);

if nargout==0,
  clf,
  %plot([data(:) y1(:) y2(:)*(max(data(:))/max(y2(:)))]),
  %plot([data(:) y1(:)*(max(data(:))/max(y1(:)))]),
  subplot(221), plot(uu), axis tight, grid on, fatlines(1.5);
  subplot(222), plot(hrfs), axis tight, grid on, fatlines(1.5);
  subplot(212), plot([data(:) y1(:)]),
  axis('tight'), grid('on'), fatlines(1.5);
  %legend('data',sprintf('fit1 (r=%.3f)',rr1),sprintf('fit2 (r=%.3f)',rr2));
  legend('data',sprintf('fit1 (r=%.3f)',rr1));
  title(sprintf('x=[%e]',xx1));
end;

return



%% sub-function definitions
%
function xx=multiHRF1_here(x0,hrfs,uu,data)
  min_type=2;
  yy=zeros(size(uu));
  %size(x0), size(hrfs), size(uu),
  for mm=1:size(hrfs,2),
    yy(:,mm)=x0(mm)*myconv(hrfs(:,mm),uu(:,mm));
  end;
  yy=sum(yy,2);

  if nargin>=4,
    if min_type==1,
      xx=1-corr(yy(:),data(:));
    elseif min_type==2,
      xx=sqrt(mean((yy(:)-data(:)).^2));
    else,
      xx=yy(:)-data(:);
    end;
  else,
    xx=yy;
  end;
return
