function y=corr_wave1(t,x_init,type,num,den,u,f1,f2)
% Usage ... y=corr_wave1(t,x,type,num,den,u,f1,f2)
%
% Makes a superimposed vector of responses according
% to the u-vector. The responses are temporally compensated
% for. A deconvolution approach is under construction ...
% f1 is the method used for obtaining the width of the
% input (if known), f2 is the matrix of x's to use when
% the input is unknown.

len_t=length(t);

if (nargin<7),
  f1=1;
end;

u_cnt=0;
flag1=0; flag2=0;
for m=1:length(u);
  if (u(m)~=0)&(~flag1),
    tmpis=m;
    u_cnt=u_cnt+1;
    flag1=1;
  end;
  if (u(m)==0)&(~flag2),
    tmpie=m;
    flag2=1;
    flag1=0;
  end;
  if (~flag1)&(flag2),
    if (tmpis==1),
      u_p(:,u_cnt)=[u(tmpis:tmpie);zeros([length(u)-(tmpie-tmpis)+1 1])];
    elseif (tmpie==length(u)),
      u_p(:,u_cnt)=[zeros([tmpis-1 1]);u(tmpis:tmpie)];
    else,
      u_p(:,u_cnt)=[zeros([tmpis-1 1]);u(tmpis:tmpie);zeros([length(u)-(tmpie-tmpis)+1 1])];
    end;
    flag2=0;
  end;
end;

if (nargin<8),
  f2=x';
  tmpcmd1=['f2=[ '];
  tmpcmd2=['f2 '];
  for m=1:u_cnt, tmpcmd2=[tmpcmd2,'f2 ']; end;
  tmpcmd3=['];'];
  tmpcmd=[tmpcmd1,tmpcmd2,tmpcmd3];
  eval(tmpcmd);
else,
  % Changes in width

  % Changes in amplitude

  % Changes in time
  
end;

for m=1:u_cnt,
  ym(m,:)=lin21(f2(:,m),t,[t(1) t(len_t)],u_p(:,m),type,1,num,den,zeros(size(t)))';
end;

y=sum(ym);
