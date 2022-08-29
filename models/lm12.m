function [a,covar,yfit]=lm1(model,lista,mfit,a,data,iter,verbose)
% Usage ... [new_a,cov_a]=lm1(model,parmlist,nofitparms,parms,data,iter,verbose)
%
% Levenburg-Marquadt optimization algorithm
% This is version 1.2
 
% Some initializations
if nargin<6, verbose=0; end;
alambda=-1.0;
chisq=0.0;
chisq_o=0.0;

ndata=length(data);
ma=length(a);

t=data(:,1);
z=data(:,2);
sig=data(:,3);

% Numerical derivative part
aa=a+randn(size(a))*0.05.*a;

% Initiial chisq
tmpcmd=['[y,dyda]=',model,'(t(m),a);'];
eval(tmpcmd);
for m=1:ndata,
  % Model here before (remember indeces)
  %tmpcmd=['[y,dyda]=',model,'(t(m),a);'];
  %eval(tmpcmd);
  chisq=chisq+(y(m)-z(m))*(y(m)-z(m))/(sig(m)*sig(m));
end;
chisq_o=chisq;

if (verbose), disp(['chi2(old)=',num2str(chisq_o)]); end;

% Initial part of algorithm
p=0;
pp=0;

% Initialization (alambda<0.0)
oneda=zeros([mfit mfit]);
atry=zeros([ma 1]);
da=zeros([ma 1]);
beta=zeros([ma 1]);
kk=mfit+1;
for j=1:ma,
  ihit=0;
  for k=1:mfit, if (lista(k)==j) ihit=ihit+1; end; end;
  if (ihit==0), 
    lista(kk)=j;
    kk=kk+1;
  elseif (ihit>1),
    error('Bad LISTA permutation(1)!');
  end; 
end;
if (kk~=(ma+1)) error('Bad LISTA permutation(2)!'); end;
alambda=0.001;

% Cof routine
for j=1:mfit,
  for k=1:j, alpha(j,k)=0.0; end;
  beta(j)=0.0;
end;
chisq=0.0;
tmpcmd=['[ymod,dyda]=',model,'(t(i),a);'];
eval(tmpcmd);
for i=1:ndata,
  % Model here before (remember indeces)
  %tmpcmd=['[ymod,dyda]=',model,'(t(i),a);'];
  %eval(tmpcmd);
  sig2i=1.0/(sig(i)*sig(i));
  dy=z(i)-ymod(m);
  for j=1:mfit,
    wt=dyda(lista(j))*sig2i;
    for k=1:j, alpha(j,k)=alpha(j,k)+wt*dyda(lista(k)); end;
    beta(j)=beta(j)+dy*wt;
  end;
  chisq=chisq+dy*dy*sig2i;
end;
for j=2:mfit,
  for k=1:j-1, alpha(k,j)=alpha(j,k); end;
end;
alpha,beta,

% Back to Min routine
ochisq=chisq;

% Iterations
for m=1:iter,

  % Core of the algorithm
  for j=1:mfit,
    for k=1:mfit, covar(j,k)=alpha(j,k); end;
    alpha(j,j)=(1+alambda)*alpha(j,j);
    oneda(j,1)=beta(j);
  end;
  % Replace gauss-jordan inversion
  oneda=inv(alpha)*beta;
  covar=inv(covar);
  for j=1:mfit, da(j)=oneda(j,1); end;
  for j=1:ma, atry(j)=a(j); end;
  for j=1:mfit, atry(lista(j))=a(lista(j))+da(j); end;
  atry,

  % Return to Cof routine
  for j=1:mfit,
    for k=1:j, alpha(j,k)=0.0; end;
    beta(j)=0.0;
  end;
  chisq=0.0;
  tmpcmd=['[ymod,dyda]=',model,'(t(i),atry);'];
  eval(tmpcmd);
  for i=1:ndata,
    % Model here before (remember indeces)
    %tmpcmd=['[ymod,dyda]=',model,'(t(i),atry);'];
    %eval(tmpcmd);
    sig2i=1.0/(sig(i)*sig(i));
    dy=z(i)-ymod(i);
    for j=1:mfit,
      wt=dyda(lista(j))*sig2i;
      for k=1:j, alpha(j,k)=alpha(j,k)+wt*dyda(lista(k)); end;
      beta(j)=beta(j)+dy*wt;
    end;
    chisq=chisq+dy*dy*sig2i;
  end;
  for j=2:mfit,
    for k=1:j-1, alpha(k,j)=alpha(j,k); end;
  end;

  % Back to Min routine
  if (chisq<ochisq),
    alambda=alambda*0.1;
    ochisq=chisq;
    for j=1:mfit,
      for k=1:mfit, alpha(j,k)=covar(j,k); end;
      beta(j)=da(j);
      a(lista(j))=atry(lista(j));
    end;
  else,
    alambda=alambda*10.0;
    chisq=ochisq;
  end;

  if (verbose), disp(['iter=',num2str(m),' chisq=',num2str(chisq)]); end;
  a,
end;

% Re-run routine with alambda=0.0
% Re-calculate yfit and chisq

