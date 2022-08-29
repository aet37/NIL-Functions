function dpdt=windkes1(t,p,q,parms)
% Usage ... dpdt=windkes1(t,p,q,parms)

% Qin= flow-rate-in
% Qout= flow-rate used to distend vessel +
%         flow-rate to peripheral vessels
%
% q = k*dpdt + p/R

K=parms(1);
R=parms(2);

dpdt(1)=(1/K)*(q-p(1)/R);

