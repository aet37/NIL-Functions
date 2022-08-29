function [x,c,c2,da]=lm1(model,dmodel,t0,tfinal,tstep,ic,consts,guess,lambda,y,std,c)
% Usage ... [x,c]=lm1(model,dmodel,t0,tfinal,tstep,ic,consts,guess,lambda,y,std,c)
%
% Levenburg-Marquadt optimization algorithm

% All parameters must be given
% The model is assumed to return a time vector and a data vector
% Sample commands:
% z=exp_model(0,100,.1,1,1,[50 5]);
% z(:,2)=z(:,2)+0.2*randn(size(z(:,2)));
% x=lm1('exp_model','dexp_model',0,100,.1,1,1,[45 2],.01,z(:,2));
% or:
% consts=[.7/5 5 .7 2 .4 .4 0 .1 .004 10 0 2.8 2.0 0.6];
% parms1=[2 1];
% parms2=[1 3];
% y=buxton1(0,65,0.1,[1 1],consts,parms2);
% n=0.05*max(y(:,2))*randn([length(y(:,2)) 1]);
% z=y(:,2)+n;
% std=ones([length(y) 1]);
% c=ones([length(y) 1]);
% lambda=0.001;
% [x,cov]=lm1('buxton1',0,65,.1,[1 1],consts,parms1,lambda,z,std,c);

if strcmp(dmodel,''),
  numeric_derivative=1;
else,
  numeric_derivative=0;
end;

iterations=100;
stop_iterating=1e-2;

nparms=length(guess);
ylen=length(y);

if nargin<12, c=ones(size(y)); end;
if nargin<11, std=ones(size(y)); end;

% Computation of the original chi2 guess
for mm=1:nparms, parms_o(mm)=guess(mm); end;
tmpcmd=['f_o=',model,'(t0,tfinal,tstep,ic,consts,parms_o);'];
eval(tmpcmd);
% Computation of the initial error
chi2_o=0;
for mm=1:ylen, e(mm)=f_o(mm,2)-y(mm); end;
for mm=1:ylen, chi2_o=chi2_o+c(mm)*e(mm)*e(mm)*(1.0/std(mm)); end;
chi2_guess=chi2_o;

% A random (normal) increment is required for the initial
% computation of beta and alpha
for mm=1:nparms, d_parms(mm)=stop_iterating*randn(1)*guess(mm); end;
d_parms=d_parms(:);

% Computation of new chi2 (guess+random)
for mm=1:nparms, parms_n(mm)=parms_o(mm)+d_parms(mm); end;
tmpcmd=['f_n=',model,'(t0,tfinal,tstep,ic,consts,parms_n);'];
eval(tmpcmd);
% Computation of the initial error
chi2_n=0;
for mm=1:ylen, e(mm)=f_n(mm,2)-y(mm); end;
for mm=1:ylen, chi2_n=chi2_n+c(mm)*e(mm)*e(mm)*(1.0/std(mm)); end;

% Convergence tracking monitors
d_parms,
chi2_n,  %c2(1)=chi2_n;
parms_n, %da(1,:)=d_parms.';

if (numeric_derivative),
  % No analytic derivative available
  % Computation of beta vector
  disp('Computation of beta vector...');
  for mm=1:nparms, tmp_parms(mm)=parms_o(mm); end;
  for k=1:nparms,
    tmp_parms(k)=parms_o(k)+d_parms(k);
    tmpcmd=['tmp_f1=',model,'(t0,tfinal,tstep,ic,consts,tmp_parms);'];
    eval(tmpcmd);
    tmp_chi2=0;
    for mm=1:ylen, f_da_tmp(mm,k)=tmp_f1(mm,2); end;
    for mm=1:ylen, e(mm)=f_da_tmp(mm,k)-y(mm); end;
    for mm=1:ylen, tmp_chi2=tmp_chi2+c(mm)*e(mm)*e(mm)*(1.0/std(mm)); end;
    beta(k)=(chi2_o-tmp_chi2)/(d_parms(k));
    tmp_parms(k)=parms_o(k);
  end;

  % Computation of alpha matrix
  % Because of the NR modification, alpha is diagonally symmetric
  disp('Computation of alpha matrix...');
  for k=1:nparms,
    for kk=k:nparms,
      if (~(kk-k)),
        % Non-diagonal entries
        % the k and kk increments are already calculated from the NR
        % expression for alpha terms
        tmp_chi2=0;
        for mm=1:ylen, tmp_chi2=tmp_chi2+c(mm)*(f_da_tmp(mm,k)-f_o(mm,2))*(f_da_tmp(mm,kk)-f_o(mm,2))/(std(mm)*d_parms(k)*d_parms(kk)); end;
        alpha(k,kk)=tmp_chi2;
        alpha(kk,k)=tmp_chi2;
      else,
        % Diagonal entries
        % the k and kk increments are already calculated from the NR
        % expression for alpha terms
        tmp_chi2=0;
        for mm=1:ylen, tmp_chi2=tmp_chi2+c(mm)*(f_o(mm,2)-f_da_tmp(mm,k))*(f_o(mm,2)-f_da_tmp(mm,kk))/(std(mm)*d_parms(k)*d_parms(kk)); end;
        alpha(k,kk)=(1+lambda)*tmp_chi2;
      end;
    end;
  end;
else,
  % Analytic derivative available
  % Computation of the beta vector
  disp('Calculating beta vector with analytic derivative...');
  for mm=1:nparms, tmp_parms(mm)=parms_o(mm); end;
  for k=1:nparms,
    tmp_parms(k)=parms_o(k)+d_parms(k);
    tmpcmd=['tmp_f=',model,'(t0,tfinal,tstep,ic,consts,tmp_parms);'];
    eval(tmpcmd);
    tmpcmd=['tmp_df=',dmodel,'(t0,tfinal,tstep,ic,consts,tmp_parms);'];
    eval(tmpcmd);
    tmp_chi2=0;
    for mm=1:ylen, tmp_chi2=tmp_chi2+c(mm)*(y(mm)-tmp_f(mm,2))*tmp_df(mm,2)/std(mm); end;
    beta(k)=tmp_chi2;
    tmp_parms(k)=parms_o(k);
  end;
  
  % Computation of the alpha matrix
  % The existence of the analytical derivative makes this easy
  % according to NR
  disp('Computation of alpha matrix with analytic derivative...');
  for k=1:nparms,
    for kk=k:nparms,
      if (~(kk-k)),
        % Diagonal terms
        tmp_parms(kk)=parms_o(kk)+d_parms(kk);
        tmpcmd=['tmp_df=',dmodel,'(t0,tfinal,tstep,ic,consts,tmp_parms);'];
        eval(tmpcmd);
        tmp_chi2=0;
        for mm=1:ylen, tmp_chi2=tmp_chi2+c(mm)*tmp_df(mm,2)*tmp_df(mm,2)/std(mm); end;
        alpha(kk,kk)=(1+lambda)*tmp_chi2;
        tmp_parms(kk)=parms_o(kk);
      else,
        % Off-diagonal terms
        tmp_parms(k)=parms_o(k)+d_parms(k);
        tmpcmd=['tmp_df=',dmodel,'(t0,tfinal,tstep,ic,consts,tmp_parms);'];
        eval(tmpcmd);
        tmp_parms(k)=parms_o(k);
        tmp_parms(kk)=parms_o(kk)+d_parms(kk);
        tmpcmd=['tmp_df2=',dmodel,'(t0,tfinal,tstep,ic,consts,tmp_parms);'];
        eval(tmpcmd);
        tmp_parms(kk)=parms_o(kk);
        tmp_chi2=0;
        for mm=1:ylen, tmp_chi2=tmp_chi2+c(mm)*tmp_df(mm,2)*tmp_df2(mm,2)/std(mm); end;
        alpha(k,kk)=tmp_chi2;
        alpha(kk,k)=tmp_chi2;
      end;
    end;
  end;
end;
  
% This section is not C terms for easeness
alpha,
beta,
parms_o=parms_n;
f_o=f_n;
chi2_o=chi2_n;

% Computing the parameter increment value using NR svd and new chi
[tmp_u,tmp_s,tmp_v]=svd(alpha);
alpha_inv=tmp_v*diag(1./diag(tmp_s))*tmp_u';
d_parms=alpha_inv*beta.';
for mm=1:nparms, parms_n(mm)=parms_o(mm)+d_parms(mm); end;
tmpcmd=['f_n=',model,'(t0,tfinal,tstep,ic,consts,parms_n);'];
eval(tmpcmd);
chi2_n=0;
for mm=1:ylen, e(mm)=f_n(mm,2)-y(mm); end;
for mm=1:ylen, chi2_n=chi2_n+c(mm)*e(mm)*e(mm)*(1.0/std(mm)); end;

% Convergence tracking monitor
d_parms,
chi2_n,  %c2(2)=chi2_n;
parms_n, %da(2,:)=d_parms.';
% first iteration complete
keyboard,

% Ready for the algorithm

l_down=0;
if (chi2_n>=chi2_o),
  disp('Increasing lambda...');
  lambda=lambda*10;
  l_down=0;
else,
  disp('Decreasing lambda...');
  lambda=lambda*0.1;
  l_down=1;
end;

% Check stopping condition
if ((chi2_o-chi2_n)<stop_iterating)&(l_down),

  % Aparently done right away
  disp('One iteration and...');

else,

  % Iterate
  for m=1:iterations,
  
    for mm=1:nparms, tmp_parms(mm)=parms_o(mm); end;

    if (numeric_derivative),

      % Recalculate beta
      for k=1:nparms,
        tmp_parms(k)=parms_o(k)+d_parms(k);
        tmpcmd=['tmp_f1=',model,'(t0,tfinal,tstep,ic,consts,tmp_parms);'];
        eval(tmpcmd);
        tmp_chi2=0;
        for mm=1:ylen, f_da_tmp(mm,k)=tmp_f1(mm,2); end;
        for mm=1:ylen, e(mm)=f_da_tmp(mm,k)-y(mm); end;
        for mm=1:ylen, tmp_chi2=tmp_chi2+c(mm)*e(mm)*e(mm)*(1.0/std(mm)); end;
        beta(k)=(tmp_chi2-chi2_o)/(d_parms(k));
        tmp_parms(k)=parms_o(k);
      end;

      % Recalculate alpha
      for k=1:nparms,
        for kk=k:nparms,
          if (~(kk-k)),
            % Non-diagonal entries
            % the k and kk increments are already calculated from the NR
            % expression for alpha terms
            tmp_chi2=0;
	    for mm=1:ylen, tmp_chi2=tmp_chi2+c(mm)*(f_da_tmp(mm,k)-f_o(mm,2))*(f_da_tmp(mm,kk)-f_o(mm,2))/(std(mm)*d_parms(k)*d_parms(kk)); end;
	    alpha(k,kk)=tmp_chi2;
            alpha(kk,k)=tmp_chi2;
          else, 
            % Diagonal entries
            % the k and kk increments are already calculated from the NR
            % expression for alpha terms
            tmp_chi2=0;
            for mm=1:ylen, tmp_chi2=tmp_chi2+c(mm)*(f_da_tmp(mm,k)-f_o(mm,2))*(f_da_tmp(mm,kk)-f_o(mm,2))/(std(mm)*d_parms(k)*d_parms(kk)); end;
            alpha(k,kk)=(1+lambda)*tmp_chi2;
          end;
        end;
      end;

    else,
  
      % Analytic derivative available
      % Computation of the beta vector
      for mm=1:nparms, tmp_parms(mm)=parms_o(mm); end;
      for k=1:nparms,
        tmp_parms(k)=parms_o(k)+d_parms(k);
        tmpcmd=['tmp_f=',model,'(t0,tfinal,tstep,ic,consts,tmp_parms);'];
        eval(tmpcmd);
        tmpcmd=['tmp_df=',dmodel,'(t0,tfinal,tstep,ic,consts,tmp_parms);'];
        eval(tmpcmd);
        tmp_chi2=0;
        for mm=1:ylen, tmp_chi2=tmp_chi2+c(mm)*2*(tmp_f(mm,2)-y(mm))*tmp_df(mm,2)/std(mm); end;
        beta(k)=-0.5*tmp_chi2;
        tmp_parms(k)=parms_o(k);
      end;
  
      % Computation of the alpha matrix
      % The existence of the analytical derivative makes this easy
      % according to NR
      for k=1:nparms,
        for kk=k:nparms,
          if (~(kk-k)),
            % Diagonal terms
            tmp_parms(kk)=parms_o(kk)+d_parms(kk);
            tmpcmd=['tmp_df=',dmodel,'(t0,tfinal,tstep,ic,consts,tmp_parms);'];
            eval(tmpcmd);
            tmp_chi2=0;
            for mm=1:ylen, tmp_chi2=tmp_chi2+c(mm)*tmp_df(mm,2)*tmp_df(mm,2)/std(mm); end;
            alpha(kk,kk)=(1+lambda)*tmp_chi2;
            tmp_parms(kk)=parms_o(kk);
          else,
            % Off-diagonal terms
            tmp_parms(k)=parms_o(k)+d_parms(k);
            tmpcmd=['tmp_df=',dmodel,'(t0,tfinal,tstep,ic,consts,tmp_parms);'];
            eval(tmpcmd);
            tmp_parms(k)=parms_o(k);
            tmp_parms(kk)=parms_o(kk)+d_parms(kk);
            tmpcmd=['tmp_df2=',dmodel,'(t0,tfinal,tstep,ic,consts,tmp_parms);'];
            eval(tmpcmd);
            tmp_parms(kk)=parms_o(kk);
            tmp_chi2=0;
            for mm=1:ylen, tmp_chi2=tmp_chi2+c(mm)*tmp_df(mm,2)*tmp_df2(mm,2)/std(mm); end;
            alpha(k,kk)=tmp_chi2;
            alpha(kk,k)=tmp_chi2;
          end;
        end;
      end;
    
    end;

    % This section is not in C terms for easeness
    parms_o=parms_n;
    f_o=f_n;
    chi2_o=chi2_n;

    % Recalculate new chi
    [tmp_u,tmp_s,tmp_v]=svd(alpha);
    alpha_inv=tmp_v*diag(1./diag(tmp_s))*tmp_u';
    d_parms=alpha_inv*beta.';
    for mm=1:nparms, parms_n(mm)=parms_o(mm)+d_parms(mm); end;
    tmpcmd=['f_n=',model,'(t0,tfinal,tstep,ic,consts,parms_n);'];
    eval(tmpcmd);
    chi2_n=0;
    for mm=1:ylen, e(mm)=f_n(mm,2)-y(mm); end;
    for mm=1:ylen, chi2_n=chi2_n+c(mm)*e(mm)*e(mm)*(1.0/std(mm)); end;

    % Convergence tracking monitor
    d_parms,
    chi2_n,  %c2(m+2)=chi2_n;
    parms_n, %da(m+2,:)=d_parms.';
    %keyboard,

    % Check stopping condition
    if ((chi2_n-chi2_o)<stop_iterating)&(l_down),
      disp('Iteration stopping criteria achieved...');
      break;
    else,
      if (chi2_n>=chi2_o),
        disp('Increasing lambda...');
        lambda=lambda*10.0;
        l_down=0;
      else,
        disp('Decreasing lambda...');
        lambda=lambda*0.1;
        l_down=1;
      end;
    end;
    
  end;

end;

% Calculating covariance matrix
disp('Calculating covariance...');
for mm=1:nparms, alpha(mm,mm)=alpha(mm,mm)/(1+lambda); end;
[tmp_u,tmp_s,tmp_v]=svd(alpha);
c=tmp_v*diag(1./diag(tmp_s))*tmp_u';
x=parms_n;
