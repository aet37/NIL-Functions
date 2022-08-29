function y=nus_fval(tp,t,x)
% Usage ... y=nus_fval(tp,t,f)
%
% Finds the point in tp which corresponds
% to x given a position in t. Linear interpolation
% is used if the point is not exact.

y=0;
for m=1:length(t),
  if t(m)==tp,
    y=x(m);
    break;
  end;
  if (m>1) & ( (tp>t(m-1))&(tp<t(m)) ),
    p=(tp-t(m-1))/(t(m)-t(m-1));
    y=x(m-1)+p*(x(m)-x(m-1));
    break;
  end;
end;

