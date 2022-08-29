function out=sumexpft(tau,tshift,tknot,t)
%
% Usage ... out=sumexpft(tau,tshift,tknot,t)
%
% Row data structure
%

tmpexp=[0];

for n=1:length(tau),
  tmpexp=tmpexp+tknot(n)*exp(-(t-tshift(n))/tau(n));
end;

out=tmpexp;
