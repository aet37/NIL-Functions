function y=corrMatch1(y1,y2,parms,parms2fit)
% Usage ... y=corrMatch1(y1,y2,parms,parms2fit)

x1=[0:length(y1)-1];
x2=[0:length(y2)-1];

x2new = alpha1*x2 + alpha0;
y2new = interp1(x2, y2, x2new, 'cubic');

ii=find(isnan(y2new));
if ~isempty(ii),
  ii2=find(diff(ii)>1);
  if isempty(ii2),
    if ii(1)==1, y2new(ii)=y2(1); else, y2new(ii)=y2(end); end
  else,
    if length(ii2)>1, ii2=ii2(1); disp('  warning: multiple breaks found'); end;
    y2new(ii(1:ii(ii2))=y2(1);
    y2new(ii(ii2+1:end))=y2(end);
  end
end

ee = y1 - y2new;

clf,
subplot(211), plot(x1,y1,x2,y2), axis tight, grid on,
subplot(212), plot(x1,y1,x2new,y2new), axis tight, grid on,
