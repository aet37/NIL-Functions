function [BOLD,vv,e,q,fout]=simpleBOLD2(CBF,parms)
% Usage ... B=simpleBOLD2(CBF,parms)
%
% parms=[dt k tau0 vk e0 b0 te]

% b0 is the field strength in tesla
% te is the echo time is seconds

% Balloon model approach
% The blood flow CBF is expected in normalized quantity
% Vv, Fout and V are calculated in normalized quantities
% and this expressed in lower-case

dt=parms(1);
k=parms(2);
tau=parms(3);
kv=parms(4);
E0=parms(5);
B0=parms(6);
TE=parms(7);

fin=CBF(:);
e=1-(1-E0).^(1./fin);

vv(1)=1;
fout(1)=1;
q(1)=1;
for mm=2:length(fin),
  vv(mm) = vv(mm-1) + (dt/tau)*(1/(1+kv))*( fin(mm-1) - ( vv(mm-1)^(1/0.4) ) );
  fout(mm) = vv(mm-1)^(1/0.4) + (kv*tau)*(vv(mm)-vv(mm-1))/dt;
  q(mm) = q(mm-1) + (dt/tau)*( fin(mm-1)*e(mm-1)/E0 - fout(mm-1)*q(mm-1)/vv(mm-1) );
end;
fout(mm)=fout(mm-1);

sb1=116.7*TE*B0*E0;
sb2=2;
sb3=2*E0-0.2;
BOLD =  sb1*(1-q) + sb2*(1-q./vv) + sb3*(1-vv);

BOLD = k*BOLD + 1;
%BOLD = k*(1-q);

if (nargout==0),
  fin=fin(:); fout=fout(:); vv=vv(:);
  subplot(311)
  plot([fin fout])
  subplot(312)
  plot(vv)
  subplot(313)
  plot([BOLD])
end;

