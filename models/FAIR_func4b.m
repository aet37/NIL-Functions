function f = FAIR_func(dM, t, t_tag, dt, T1a, T1b, M0b, alpha)
% function f = FAIR_func(dM, t, t_tag, TT, T1a, T1b, M0b, alpha)
%

% defaults    
if (nargin<8), alpha=0.9; end;
if (nargin<7), M0b=1000; end;
if (nargin<6), T1b=1.3; end;
if (nargin<5), T1a=1.3; end;
if (nargin<4), dt=1.5; end;
if (nargin<3), t_tag=2; end;

%T1prime=1/(1/T1b+f/1);
T1prime=T1b; 

f=zeros(size(dM));

for i=1:length(t),

  if (t(i) <= dt),
    aa=0;
    f(i)=0;
  elseif ((t(i) > dt)&(t(i)<=dt+t_tag)),
    q=1-exp(-((t(i)-dt)/T1prime));
    %dM_guess(i) = (2 * M0b* f * T1prime* alpha * exp(-dt/T1a ))*q;
    aa=1/(2*M0b*T1prime*alpha*exp(-dt/T1a)*q);
    f(i)=dM(i)/(2*M0b*T1prime*alpha*exp(-dt/T1a)*q);
  elseif (t(i) > (dt+t_tag)),
    q=1-exp(-t_tag/T1prime);
    %dM_guess(i)=(2*M0b*f*T1prime*alpha*exp(-dt/T1a)*exp(-(t(i)-t_tag-dt)/T1prime))*q;
    aa=1/(2*M0b*T1prime*alpha*exp(-dt/T1a)*exp(-(t(i)-t_tag-dt)/T1prime)*q);
    f(i)=dM(i)/(2*M0b*T1prime*alpha*exp(-dt/T1a)*exp(-(t(i)-t_tag-dt)/T1prime)*q);
  end;

end;

if (nargout==0),
  sublot(211)
  plot(f)
  subplot(212)
  plot(dM)
  disp(sprinf('  a= %f',aa));
end; 

