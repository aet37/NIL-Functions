function [s,i]=nmrspec(x,t,phi,nsplits,splitfreq,type,base,freq)
% Usage ... [f,i]=nmrspec(x,t,phi,nsplits,splitfreq,type,base,freq)
%
% Generates a NMR Spectra according to the paramters x
% used and the waveform type selected. The areas of the
% resonances are returned in i.
% Types= 1-Loren, 2-Gauss, 3-Voigt
% Baseline correction is going to be done at the end if
% extra parameters are added (each for the order of the
% polyfit that is going to be used as baseline).

t=t(:);
ts=t(2)-t(1);
text=t(length(t))-t(1);
f=[1/text:1/text:1/ts+1/text];
f=f(:);

phi0=phi(:,1);
phi1=phi(:,2);

if nargin<8, freq=0; end;
if nargin<7, base=zeros(size(t)); end;
if nargin<6, type=1; end;
if base(1)==0, base=zeros(size(t)); end;

if type==3, 	% Voigt
  nparms=4;
elseif type==2, % Gauss
  nparms=3;
else,		% Lorentzian
  nparms=3;
end;

n_resonances=length(x)/nparms;
st=zeros([length(t) n_resonances]);
sf=zeros([length(t) n_resonances]);
si=zeros([n_resonances 1]);

if type==3,		% Voigt 

  for k=1:n_resonances,
    mamp=x(nparms*k-3);
    mphs=exp(+j*(phi0(k)+phi1(k)*t));
    moff=exp(-j.*(f-x(nparms*k-2)).*t);
    s_loren=exp(-x(nparms*k-1)*t);
    s_gauss=exp(-x(nparms*k)*x(nparms*k)*t.*t);
    s_voigt=mamp.*mphs.*moff.*s_loren.*s_gauss;
    st(:,k)=s_voigt;
    sf(:,k)=zeros(size(f));	% need freq expr (conv)
    si(k)=trapz(f,sf(:,k));	% need int expr
  end;

elseif type==2,		% Gauss

  for k=1:n_resonances,
    s_gauss=0;
    [splitw,df]=getsplitweights(nsplits(k),splitfreq(k));
    for kk=1:nsplits(k)+1,
      mamp=splitw(kk)*x(nparms*k-2);
      mphs=exp(+j*(phi0(k)+phi1(k)*t));
      moff=exp(-j.*(f-x(nparms*k-1)+df(kk)).*t);
      mdec=exp(-x(nparms*k)*x(nparms*k)*t.*t);
      s_gauss=mamp.*mphs.*moff.*mdec;
      st(:,k)=st(:,k)+s_gauss;
      sf(:,k)=sf(:,k)+splitw(kk)*(1/sqrt(2*pi))*x(nparms*k-2)*(1/x(nparms*k))*exp(-(1/x(nparms*k))*(1/x(nparms*k))*(f-x(nparms*k-1)+df(kk)).*(f-x(nparms*k-1)+df(kk)));
      si(k)=trapz(f,sf(:,k));	% need int expr
    end;
  end;

else,			% Lorentzian

  for k=1:n_resonances,
    s_loren=0;
    [splitw,df]=getsplitweights(nsplits(k),splitfreq(k));
    for kk=1:nsplits(k)+1,
      mamp=splitw(kk)*x(nparms*k-2);
      mphs=exp(+j*(phi0(k)+phi1(k)*t));
      moff=exp(+j*2*pi*(x(nparms*k-1)+df(kk)).*t);
      mdec=exp(-x(nparms*k)*t);
      s_loren=mamp.*mphs.*moff.*mdec;
      st(:,k)=st(:,k)+s_loren;
      sf(:,k)=sf(:,k)+splitw(kk)*x(nparms*k-2)*x(nparms*k)./(1+(1/x(nparms*k))*(1/x(nparms*k))*(f-x(nparms*k-1)+df(kk)).*(f-x(nparms*k-1)+df(kk)));
      si(k)=trapz(f,sf(:,k));	% need int expr
    end;
  end;

end;

s=zeros(size(t));
for k=1:n_resonances,
  if freq,
    t=f;
    s=s+sf(:,k);
  else,
    s=s+st(:,k);
  end;
end;

% add baseline
s=s+base;

if nargout==0,
  plot(t,real(s),t,imag(s)),
end;

