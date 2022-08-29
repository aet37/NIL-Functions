function dM_guess = FAIR_func(guess, t, t_tag, T1a, T1b, M0b, alpha, uptakedtdata)
% function result = FAIR_func(guess, t, T1, M0b, alpha)
%

if (nargin==8) flowcalc=1; else, flowcalc=0; end;

% defaults    
if (nargin<7), alpha=0.9; end;
if (nargin<6), M0b=1000; end;
if (nargin<5), T1b=1.3; end;
if (nargin<4), T1a=1.3; end;
if (nargin<3), t_tag=2; end;

if (flowcalc), 
  f =   guess(1);
  dt = uptakedtdata(2);
  t = uptakedtdata(1);
else,
  f =   guess(1);
  dt =  guess(2);
end;
 
T1prime=1/(1/T1b+f/1);
%if (flowcalc), T1prime=T1b; end;
dM_guess=zeros(size(t));

%f,dt,T1prime,M0b,t

for i=1:length(t),

  if (t(i) <= dt)
    dM_guess(i) = 0;
    msg1=sprintf(' 1: dM= %f',dM_guess(i));

  elseif ((t(i) > dt)&&(t(i)<=dt+t_tag))
    q=1-exp(-((t(i)-dt)/T1prime));
    dM_guess(i) = (2 * M0b* f * T1prime* alpha * exp(-dt/T1a ))*q;
    msg1=sprintf(' 2: dM= %f, T1prime= %f, exp= %f, q= %f',dM_guess,T1prime,exp(-dt/T1a),q);

  elseif (t(i) > (dt+t_tag))
    q=1-exp(-t_tag/T1prime);
    dM_guess(i)=(2*M0b*f*T1prime*alpha*exp(-dt/T1a)*exp(-(t(i)-t_tag-dt)/T1prime))*q;
    msg1=sprintf(' 3: dM= %f, T1prime= %f, exp= %f, exp= %f, q= %f',dM_guess,T1prime,exp(-dt/T1a),exp(-(t(i)-t_tag-dt)/T1prime),q);

  end;

end;

%disp(msg1);

if (flowcalc),
  dM_guessB=dM_guess;
  dM_guess = (dM_guess - uptakedtdata(3)).^2;
  %[dM_guess],
end;
 
