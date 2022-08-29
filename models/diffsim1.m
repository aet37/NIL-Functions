function x=diffsim1(n,nsteps,D,tau,seed1)
% Usage ... f=diffsim1(n,nsteps,D,tau,seed1)

if nargin<5, seed1=0; end;
if nargin<4, tau=1e-3; end;	% units: s
if nargin<3, D=1e-5; end;	% units: cm2/s

msq_displ=2*D*tau;
psi=sqrt(msq_displ);

x=zeros([n 1]);

if ~seed1, seed1=sum(100*clock); end;
rand('seed',seed1);

for m=1:steps,

  s=rand([n 1])-0.5;
  a=zeros([n 1]);

  ls=find(s<0);
  rs=find(s>=0);
  if ~isempty(ls),
    for m=1:length(ls), a(ls(m))=-1; end;
  end;
  if ~isempty(rs),
    for m=1:length(rs), a(rs(m))=+1; end;
  end;

  x=x+psi*a;

end; 
