function yout=apostolos_arima(y,o_ar,o_i,o_ma)
% Usage ... y_out=apostolos_arima(y,o_ar,o_i,o_ma)

if ~exist('o_ar'), o_ar=15; end;
if ~exist('o_i'),  o_i=1;   end;
if ~exist('o_ma'), o_ma=1;  end;

if length(o_ar),
  o_i=o_ar(2);
  o_ma=o_ar(3);
  o_ar=o_ar(1);
  %[o_ar o_i o_ma],
end;

ar_order = o_ar;
difference_order = o_i;
ma_order = o_ma;

% one column of data
time_series = y;

for mm=1:size(y,2),
% this line is not necessary if there is no differencing for the model
if difference_order,
  differenced_time_series = iddata(diff(time_series(:,mm), difference_order), []);
else,
  differenced_time_series = iddata(time_series(:,mm), []);
end;
model = armax(differenced_time_series, [ar_order ma_order]);
rm = resid(model, differenced_time_series);

% residuals is a column vector
residuals = rm.y;

yout(:,mm)=residuals;
%yout(2:end+1)=yout;
%yout(1)=yout(2);
end;

do_myar=0;
if nargout==0, do_myar=1; end;

if do_myar,
  % my ar
  aryp=aryule(y-mean(y),o_ar);
  yf=filter(aryp,1,y-mean(y));
  yout2=yf+mean(y); 
  %yout=yout2;
end;

if nargout==0,
  size(y), size(yout),
  clf,
  subplot(211)
  plot([y(:) yout(:)+mean(y)]),
  subplot(212)
  plot(abs([fft(y(:)-mean(y)) fft(yout(:))]))
end;

