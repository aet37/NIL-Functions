function [y,xi,xi_not]=myOutlierRemoval1(x,thr,itype,iibias)
% Usage ... [y,xi,xi_not]=myOutlierRemoval1(x,thr,itype,iibias,ii0_or_meanstd)
%
% This function attempts to replace outlier sample points exceeding thr
% (x>thr) using interpolator itype. If the first or last points are outliers, 
% they are replaced by the nearest non-outlier point.
% To make a custom thr use '<=8'
%
% For ex, plot(myOutlierRemoval1(rr1(:,1),'< 8'))
%         tc_new=myOutlierRemoval1(tc(:),{'20',ii0},'linear',ii1);

if ~exist('itype','var'), itype=[]; end;
if isempty(itype), itype='linear'; end;

ii=[1:length(x)]';

if exist('iibias','var'),
    if iscell(thr),
        thr_orig=thr;
        clear thr
        thr=thr_orig{1};
        ii0=thr_orig{2};
        xms=[mean(x(ii0)) std(x(ii0))];
        if ischar(thr),
            thrval=xms(2)*str2num(thr);
        else,
            thrval=thr;
        end
        disp(sprintf('  avg=%f  std=%f  thr=%f',xms(1),xms(2),xms(1)+thrval));
        xi_out=find( abs(x(iibias)-xms(1)) > thrval );
        xi_in=find( abs(x(iibias)-xms(1)) <= thrval );
        xi_not=i2i(ii,'in',iibias(xi_out));
        xi=i2i(ii,'notin',iibias(xi_out));
        y=interp1(xi,x(xi),ii);
        if nargout==0,
            plot([x(:) y(:)]),
            axis tight, grid on, drawnow,
        end
        return,
    end
end

if ischar(thr),
  disp(sprintf('  xi=find(x%s);',thr));
  eval(sprintf('xi=find(x%s);',thr));
else,
  if length(thr)==2,
    xi=find((x<thr(1))&(x>thr(2)));
  else, 
    xi=find(x>thr(1));
  end;
end;

y=x;

if ~isempty(xi),
  xi_not=inoti(xi,[1:length(x)]);

  if xi(1)==1,
  disp(sprintf('  replacing index 1 with index %d',xi_not(1)));
  y(1)=x(xi_not(1));
  end;
  if xi(end)==length(x),
    disp(sprintf('  replacing index end with index %d',xi_not(end)));
    y(end)=x(xi_not(end));
  end;
  y(xi)=interp1(xi_not,y(xi_not),xi,itype);

else,
  disp('  no outliers found at selected thr');
end;

if nargout==0,
  plot([x(:) y(:)]),
  axis tight, grid on,
  drawnow,
  clear y xi xi_not
end;
