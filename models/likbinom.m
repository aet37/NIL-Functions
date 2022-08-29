function [f,g]=likbinom(x,n,M)
% Usage ... [f,g]=likbinom(x,n,M)
%
% x = [pa pi lambda]
% n = [N0 N1 N2 ... NM]

pa=x(1);
pi=x(2);
lambda=x(3);

L=0;
dLdpa=0;
dLdpi=0;
dLdl=0;
for k=0:M,
  Larg = lambda*(pa^k)*((1-pa)^(M-k)) + (1-lambda)*(pi^k)*((1-pi)^(M-k));
  L = L + n(k+1)*log(Larg);
  if nargout==2,
    dLdpa = dLdpa + n(k+1)*( lambda*k*(pa^(k-1))*((1-pa)^(M-k)) - ...
                   lambda*(pa^k)*(M-k)*((1-pa)^(M-k-1)) )/Larg;
    dLdpi = dLdpi + n(k+1)*( (1-lambda)*k*(pi^(k-1))*((1-pi)^(M-k)) - ...
                   (1-lambda)*(pi^k)*(M-k)*((1-pi)^(M-k-1)) )/Larg;
    dLdl = dLdl + n(k+1)*( (pa^k)*((1-pa)^(M-k)) - (pi^k)*((1-pi)^(M-k)) )/Larg;
  end;
end;

f = -1*L;			% for max likelihood need to solve as min likelihood
if nargout==2,
  g = -1*[ dLdpa dLdpi dLdl ];	% for max likelihood need to solve as min likelihood
end;

