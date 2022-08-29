function f=fin_fun(time,h,a,fin_prev,del,width,ampl)
% Usage f=fin_fun(time,h,a,fin_prev,del,width,ampl)

%h=time(2)-time(1);
%f(1)=ic;
%for m=2:length(time),
%  f(m)=-(1/a)*h*f(m-1)+(1/a)*h*x(m-1)+f(m-1);
%end;

if (((time+h)<=(del+width))&((time+h)>=(del)))
  inputsample=ampl;
else,
  inputsample=0;
end;

f= (-1/a)*h*fin_prev + (1/a)*h*inputsample + fin_prev;
