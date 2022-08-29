
clear all
load /net/stanley/data/skahwati/sept17_data/MZ/ASE/nk
save rocdata NN

clear all
load rocdata
load /net/stanley/data/skahwati/sept17_data/MZ/ASE/lambdas

NNk=NN(:,:,2);
[nthr,M]=size(NNk);
nx=2*nthr;

x0([1:2:nx])=0.5*ones([1 length([1:2:nx])]); x0([2:2:nx])=0.5*ones([1 length([2:2:nx])]);
lb([1:2:nx])=0.0*ones([1 length([1:2:nx])]); lb([2:2:nx])=0.0*ones([1 length([2:2:nx])]);
ub([1:2:nx])=1.0*ones([1 length([1:2:nx])]); ub([2:2:nx])=1.0*ones([1 length([2:2:nx])]);

opt=optimset('lsqnonlin');
opt.Display='iter';
opt.TolFun=1e-8;
opt.TolX=1e-8;
%opt.Jacobian='on';
xx=lsqnonlin('relfmrif',x0,lb,ub,opt,NNk,lambdak);
[tmp1,tmp2,En]=relfmrif(xx,NNk,lambdak);
clear tmp1 tmp2

lambda=lambdak
pa=xx([1:2:end]);
pi=xx([2:2:end]);

NNk,round(En),(NNk-En).^2,

ii=find(sum(((NNk-En).^2)')<2500);

clf
%subplot(211)
plot(pi(:,ii),pa(:,ii),'g-',pi,pa,'gx',pa(:,ii),pi(:,ii),'b-',pa(:,ii),pi(:,ii),'bx')
xlabel('Pi')
ylabel('Pa')
title(sprintf('lambda= %f (%f)',lambda,1-lambda));

%A2=[]; b2=[]; Aeq2=[]; beq2=[]; 
%opt2=optimset('fmincon');
%opt2.Display='iter';
%opt2.TolFun=1e-8;
%opt2.TolX=1e-8;
%xx2=fmincon('likbinomf',x0,[],[],[],[],lb,ub,[],opt2,NNk);
%
%lambda2=xx2(1);
%pa2=xx2([2:2:end]);
%pi2=xx2([3:2:end]);
%
%subplot(212)
%plot(pi2,pa2,'-',pi2,pa2,'x')
%title(sprintf('lambder2= %f',lambda2))
%xlabel('Pi')
%ylabel('Pa')
%
