
clear

t=[1e-3:1e-3:30e-3];

for m=1:length(t),
  dndt(:,m)=diff2(1e5,t(m),10*m);
end;

