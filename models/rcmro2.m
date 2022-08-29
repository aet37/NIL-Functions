function r=rcmro2(f,b,m,v)
% Usage ... r=rcmro2(f,b,m,v)
% can be organized in columns

% from Davis, et al, PNAS 95:1834 (1998) ...
% 
% to calculate m we need to have the relative changes for at least
% bold and cbf in a hypercapnia challenge, then we use
%
%   M = Bh -1 / ( 1 - Vh / Fh^1.5 ) ~ Bh -1 / ( 1 - Fh^-1.1 )
%
% then to calculate rCMRO2 we use
%
%   rCMRO2 = Ft.Ft^(-a/b).( 1 - (Bt - 1)/M )^(1/b)
%
%          = Ft.Vt^(-1/b).( 1 - (Bt - 1)/M )^(1/b)
%

alpha=0.4;

if (size(f,1)==1), f=f(:); end;
if (nargin<4), v=f.^alpha; end;
if (size(v,1)==1), v=v(:); end;
if (size(b,1)==1), b=b(:); end;
if (sum(sum((b-1)>=m))),
  bmax=max(max(b-1));
  disp(sprintf('Warning: B-1 > M !!! %f > %f !!! Using ABS',bmax,m));
  absflag=1;
else,
  absflag=0;
end;

if (size(f,2)==1),
  if (length(m)==2),
    M=(m(2)-1)/(1-(m(1)^(-1.1)));
  elseif (length(m)==3),
    M=(m(2)-1)/(1-m(3)/(m(1)^1.5));
  else,
    M=m;
  end;
else,
  M=m;
end;

beta=1.5;
r=zeros(size(f));
for n=1:size(f,2),
  r(:,n)=(f(:,n).^(beta))./v(:,n);
  %r(:,n)=f(:,n).*(v(:,n).^(-1/beta));
  r(:,n)=r(:,n).*( 1 - (b(:,n)-1)./M(n) );
  r(:,n)=r(:,n).^(1/beta);
end;
if absflag, r=abs(r); end;

if (mean(mean(r))<1), disp('Warning: M appears low (rCMRO2_bar<1)'); end;

if nargout==0,
  t=[1:length(f)];
  subplot(311)
  plot(t,f,t,v,t,f.^0.4)
  subplot(312)
  plot(t,b)
  subplot(313)
  plot(t,r)
end;

