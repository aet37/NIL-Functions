
clear all

% This simulation duplicates the work presented by R. Cox and
% P. Bandettini in ISMRM98 #244 (also #161)

% The simulations attempts to unravel the optimum ISI for 2
% conditions being tested with M stimulations and a fixed scan
% time

% Note that what we want is to be able to estimate the response
% coefficient (namely decrease the variance of the estimate) in
% order to obtain the most reliable responses 

% The baseline can not be used as a condition because then
% we would have to add more parameters???

alpha=1.0;
beta=1.0;
sigma=0.25;
seed1=sum(100*clock);

delay=1.0;
bpower=8.6;
tau=0.55;

% iterate through M=[10 20 40 100] and L=[20 10 5 2]
% to keep scan time samples (N*L) the same

dt=1.0;					% sampling time
M=[10 18 24 30 36 45 60 90 120 180];	% n reps of the stimulus
L=(1/dt)*[36 20 15 12 10 8 6 4 3 2];		% n samples within conditio
NN=M.*L; N=NN(1);				% NN should be all the same

baseline=beta*ones([N 1]);
randn('seed',seed1);
noise=sigma*randn([N 1]);

for mm=1:length(M),

  T=dt*L(mm);		% ISI
  A=dt*M(mm)*L(mm);	% scan time
  tscan=[dt:dt:A]';	% scan vector

  % Assuming that the responses are very short so the
  % impulse response function will sufice as representation
  % of the responses
  % To add jitter this part has to be modified
  rt=zeros([N 1]);
  for m=0:M(mm)-1,
    rt=rt+gammafun2(tscan,delay+m*T,tau,bpower,1.0,1);
    %plot(tscan,rt), pause,
  end;

  rn=zeros([N 1]);
  xn=zeros([N 1]);
  for n=1:N,
    rn(n)=rt(n);
    xn(n) = alpha*rn(n) + baseline(n) + noise(n);
  end;

  e=ones([N 1]);

  P = [rn e];

  x = P * [alpha;beta] + noise;

  % Note that these are simple least-squares estimates
  % which are assuming that the model is linear and so
  % should be the responses
  % Does this mean that noise will be the factor making
  % the difference???

  ab_hat=inv(P'*P)*P'*x;

  cov_hat=inv(P'*P);
  cov_ab_hat=sigma*sigma*cov_hat;

  x1(:,mm)=x;
  r1(:,mm)=rn;
  abhat1(:,mm)=ab_hat;
  covnabhat1(:,mm)=reshape(cov_ab_hat,[prod(size(cov_ab_hat)) 1]);
  covabhat1(:,mm)=reshape(cov_hat,[prod(size(cov_hat)) 1]);

end;

% clean-up desktop
clear A T ab_hat b cov_ab_hat e m mm n rn rt x xn

subplot(211)
plot(L*dt,abhat1(1,:))
subplot(212)
plot(L*dt,covabhat1(1,:))

% So there is something fishy in the beggining, definitely not
% due to sampling, but it is related to the delay of the gamma
% function (obviously) however it looks like numerical error
% (or is it?)... the error in the mean is strictly due to the
% noise so that is no concern... one way to chech the veracity
% of the results here is to actually do the selective averaging
% and looking at the results... two different flavors for the
% selective averaging shouls be used too, making the averaging
% window the size of the ISI or a fixed size G (and compare
% these to a typical gammafun)...
