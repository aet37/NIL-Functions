function out=expfitse(y,t,firstavg,lastavg,maxnoexp,maxerr,tolerance)
%
% Usage ... out=expfitse(y,t,firstavg,lastavg,maxnoexp,maxerr,tolerance)
%
% Works along with sumexpft which is an exponent sum of the
% form: 
%    sumexpft(tau,tshift,tknot,t)
%    y = sum [ tknot*exp(-(t-tshift)/tau)) ]
%

lastval=mean( y(length(y)-lastavg:length(y)) );
frstval=mean( y(1:firstavg+1) );

tmpy=y-lastval;

% Stage I

tmpval=tmpy(1)*(1-exp(-1));
n=1;
while (tmpval<=tmpy(n)),
  n=n+1;
end;
tmplam0=t(n);
tmpcoeff0=frstval-lastval;
tmpshift0=0;

tmpexp0=sumexpft(tmplam0,tmpshift0,tmpcoeff0,t);
tmpserr=cumsum(esqr(abs(tmpexp0-tmpy)));
ext=0;

while (~ext),
 tmpserr2=cumsum(esqr(abs(tmpy-sumexpft(tmplam0-tolerance,tmpshift0,tmpcoeff0,t))));
 if ( tmpserr>tmpserr2 ), tmplam0=tmplam0-tolerance; ext=0; else ext=1; end;
end;

% Stage II

% Output

tmplam=tmplam0
tmpshift=tmpshift0
tmpcoeff=tmpcoeff0

out=lastval+sumexpft(tmplam,tmpshift,tmpcoeff,t);
