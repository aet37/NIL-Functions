function [ff,ff2]=FAIR_func5b(T1,transit_time,M0,acqparms,modelparms,dM)
% Usage ... [ff]=FAIR_func5b(T1,TT,M0,acqparms,modelparms,dM)
%
% ff is the flowfactor assuming a flow guess of 0.01 1/s
% if dM is used, then ff is the flow in units of ml/min/100ml-tissue
% acqparms=[t_tag t_delay TR]
% modelparms=[T1art lambda_prime alpha rho lambda  convkerntype]
% T1 can be a vector

verboseflag=1;

if nargin<6, calcflow=0; else, calcflow=1; end;
if nargin<5,
  modelparms=[1.5 0.7 0.9 1 1 1];
end;
if (length(modelparms)<1), modelparms(1)=1.5; end;
if (length(modelparms)<2), modelparms(1)=0.7; end;
if (length(modelparms)<3), modelparms(1)=0.9; end;
if (length(modelparms)<4), modelparms(1)=1; end;
if (length(modelparms)<5), modelparms(1)=1; end;
if (length(modelparms)<6), modelparms(1)=1; end;
if nargin<4,
  acqparms=[1.5 0.1 2];
end;

%ASL input function to use  (1=boxcar, 2=boxcar*exp, 3=boxcar*gaussian)
model=modelparms(6);

%Constants for the model (based on Buxton's)
T1a=modelparms(1);  		%T1 of arterial blood in s
lamda_prime=modelparms(2);
alpha=modelparms(3); 		% degree of inversion (typically 0.8-1.0)
rho=modelparms(4);    		% water extraction fraction 
lamda=modelparms(5);  		% blood brain partition coefficient

f = 0.01; % initial guess! -- 0.01-1.00s corresponds to 60ml/100g/min 

tag_duration=acqparms(1);
t_delay=acqparms(2);  		%delay after tag bef im acq, in s
TR=acqparms(3);

if (TR>3), nTR=4; else, nTR=10; end; 	%number f repetitions to plot
dt=1e-3;				%step size of simulation in s
time=[0:dt:TR];
total_time=0:dt:nTR*TR;  

for q=1:nTR,
  vec(q)=(tag_duration+t_delay+(q-1)*TR)/dt;
end;

Mob=M0/lamda_prime;

label=zeros(size(total_time));
for q=1:nTR,
  if(mod(q,2)),
    label=label+(total_time>(q-1)*TR).*(total_time<=(q-1)*TR+tag_duration);
  else,
    label=label;
  end;
end;

c=zeros(size(total_time));
for q=1:nTR,
  if(mod(q,2)),
    c=c+(total_time>=transit_time+(q-1)*TR-1000*eps).*(total_time<=tag_duration+transit_time+(q-1)*TR+1000*eps);
    %need eps part to avoid matlab quantization errors  
  else,
    c=c;
  end;
end;

nsamples=length(T1);
ff=zeros(nsamples,1);
ff2=zeros(nsamples,1);
for mm=1:nsamples,

   if (verboseflag),
     disp(sprintf(' calculating entry #%d/%d ...',mm,nsamples));
   end;

   T1b = T1(mm);  %T1 of brain in s
   T1eff = 1/(f/lamda+1/T1b);
                
   r=exp(-f.*total_time./lamda);  %residue function of Buxton model
   m=rho*exp(-total_time./T1b);   %T1 decay function of Buxton model
   decay=r.*m;              	  %combined decay function
                
   if(model==1),
     cc=c*alpha*exp(-transit_time/T1a);
     answer=2*Mob*f*conv(cc,decay).*dt;
   elseif(model==2),   
     k=2;
     a=exp(-k*time);
     a=a/(sum(a)*dt);
     c2=conv(c,a).*dt.*exp(-transit_time./T1a);
     answer=2*Mob*alpha*f*conv(c2, decay).*dt;
   elseif(model==3),
     a2=gausswin(round(1/dt));         %width of Gaussian blurring kernel
     a2=a2/(sum(a2)*dt);
     c3=conv(c,a2).*dt.*exp(-transit_time./T1a);
     answer=2*Mob*alpha*f*conv(c3, decay).*dt;
   end;
                
   tmp=diff(answer(round(vec)));
   % this linear scaling ignores accouting for the q-term (varies little)
   ff(mm)=f/abs(tmp(end));
   
   %alternate model (eq. 5 from Buxton) - doesn't take into account steady
   %state
   our_t=tag_duration+t_delay;  %the acquisition time
   if((our_t)<transit_time),
     ff2(mm)=0;
   elseif(((our_t)>=transit_time) & ((our_t)<(transit_time+tag_duration))),
       q=1-exp(-(our_t-transit_time)/T1eff);
       ff2(mm)=1/(2*Mob*T1eff*alpha*exp(-transit_time/T1a)*q);
   elseif((our_t)>(transit_time+tag_duration)),
       q=1-exp(-tag_duration/T1eff);
       ff2(mm)=1/(2*Mob*T1eff*alpha*exp(-transit_time/T1a)*exp(-((our_t)-tag_duration-transit_time)/T1eff)*q);
   end;
   
end;

if (calcflow),
  ff=ff*dM*6000;
  ff2=ff2*dM*6000;
end;

