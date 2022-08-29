
clear

D=1e-5;
tau=5e-4;

d(:,1)=zeros([1e4 1]); 
for m=2:100,
  d(:,m)=diffdisp(1e4,m-1,D,tau,10*m);
  %hist(d,100),
  %keyboard,
end;

t=tau*[0:99];
plot(t,mean(d.*d))

