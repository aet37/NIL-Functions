function p=windkes1b(t,q,p0,R,K)
% Usage ... p=windkes1b(t,q,p0,R,K)

dt=t(2)-t(1);
a1=exp(-t/(R*K));
a2=cumsum(q.*a1*dt);
p=(1/K)*a1.*a2+p0*a1;

if nargout==0,
  subplot(211)
  plot(t,q)
  xlabel('Time')
  ylabel('Qin')
  subplot(212)
  plot(t,p)
  xlabel('Time')
  ylabel('Pressure')
end;
