
clear all
load /net/stanley/data/skahwati/jun22_data/splx_1shot/nk
save rocdata NN

clear all
load rocdata

NNk=NN(:,:,2);
[nthr,M]=size(NNk);
nx=2*nthr+1;

x0(1)=0.02;
x0([2:2:nx])=0.5*ones([1 length([2:2:nx])]); x0([3:2:nx])=0.5*ones([1 length([3:2:nx])]);
lb(1)=0.00;
lb([2:2:nx])=0.0*ones([1 length([2:2:nx])]); lb([3:2:nx])=0.0*ones([1 length([3:2:nx])]);
ub(1)=1.00;
ub([2:2:nx])=1.0*ones([1 length([2:2:nx])]); ub([3:2:nx])=1.0*ones([1 length([3:2:nx])]);

opt=optimset('lsqnonlin');
opt.Display='iter';
opt.TolFun=1e-8;
opt.TolX=1e-8;
%opt.Jacobian='on';
xx=lsqnonlin('relfmrif',x0,lb,ub,opt,NNk);
[tmp1,tmp2,En]=relfmrif(xx,NNk);
clear tmp1 tmp2

lambda=xx(1);
pa=xx([2:2:end]);
pi=xx([3:2:end]);

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
