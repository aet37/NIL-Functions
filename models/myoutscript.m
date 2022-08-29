function f=myoutscript(xvec,ymat,zmat,tlab,stlab,xlab,ylab,gridlab,fax)

[yr,yc]=size(ymat);

clg

subplot(2,2,1)
plot(xvec,ymat(:,1),'--',xvec,zmat(:,1));
xlabel(xlab); ylabel(ylab); eval(['grid ',gridlab]); axis(fax);
eval(['title(''',tlab,' - ',stlab(1,:),''');']);
subplot(2,2,2)
plot(xvec,ymat(:,2),'--',xvec,zmat(:,2));
xlabel(xlab); ylabel(ylab); eval(['grid ',gridlab]); axis(fax);
eval(['title(''',tlab,' - ',stlab(2,:),''');']);
subplot(2,2,3)
plot(xvec,ymat(:,3),'--',xvec,zmat(:,3));
xlabel(xlab); ylabel(ylab); eval(['grid ',gridlab]); axis(fax);
eval(['title(''',tlab,' - ',stlab(3,:),''');']);
subplot(2,2,4)
plot(xvec,ymat(:,4),'--',xvec,zmat(:,4));
xlabel(xlab); ylabel(ylab); eval(['grid ',gridlab]); axis(fax);
eval(['title(''',tlab,' - ',stlab(4,:),''');']);

f=1;