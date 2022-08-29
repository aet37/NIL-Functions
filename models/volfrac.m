function [D,DD]=volReqL(L,Req,V)
% Usage ... [D,DD]=volReqL(L,Req,V)

%Req = dP / Q;
Deq = ((128*mu*L)/(pi*Req))^(1/4);
Veq = pi*Deq*Deq*L;

if (nargin<3),
  D=Deq;
  DD=0;
else,
  D=(V-Veq)^2;
  DD=Deq;
end;

