function y=LSI_k2tau(kim,T)
% Usage ... y=LSI_k2tau(kim,T)

tauf=0.25;

tau=tauf*[1:1e5]/1e5;
KT=sqrt((tau/(2*T)).*(1-exp(-2*T./tau)));

if size(kim,3)>1,
  for mm=1:size(kim,3),
    tmpkim=kim(:,:,mm);
    kim_vec=reshape(tmpkim,prod(size(tmpkim)),1);
    tau_vec=interp1(KT,tau,kim_vec);
    y(:,:,mm)=reshape(tau_vec,size(tmpkim,1),size(tmpkim,2));
  end;
else,
  kim_vec=reshape(kim,prod(size(kim)),1);
  tau_vec=interp1(KT,tau,kim_vec);
  y=reshape(tau_vec,size(kim,1),size(kim,2));
end;

if nargout==0,
  clf, subplot(121), show(kim), subplot(122), show(y),
  clear y
end;
