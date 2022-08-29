fk=1/5.2;

leaves = 6;
ww = exp(i*2*pi/leaves);
nsegs = 6;
g = [ 1 ];
for lp = 1:nsegs;
 g = [g ww^(lp).*ones([1 lp])]; 
end
k = [0 cumsum(g) ];

lenk = length(k)-1

plot(fk*k(1:lenk),'x');
hold
plot(fk*k(1:lenk),'-');
for lp = 2:leaves;
  plot(fk*k(1:lenk).*(ww^(lp-1)),'o');
  plot(fk*k(1:lenk).*(ww^(lp-1)),':');
end
hold
axis('image')
%length(k)
%return
ylabel('kz');
xlabel('ky');

return;
pause

leaves = 4;
ww = exp(i*2*pi/leaves);
nsegs = 6;
g = [ 1 ];
for lp = 1:nsegs;
 g = [g ww^(lp).*ones([1 lp*2])]; 
end
k = [0 cumsum(g) ];

plot(fk*k,'x');
hold
plot(fk*k,'-');
for lp = 2:leaves;
  plot(fk*k.*(ww^(lp-1)),'o');
  plot(fk*k.*(ww^(lp-1)),':');
end
hold
axis('image')

pause

leaves = 6;
ww = exp(i*2*pi/leaves);
nsegs = 8;
g = [ 1 ];
g2 = [ 2 ];
g = [g ww^(1).*ones([1 2])]; 
g2 = [g2 ww^(1).*ones([1 2])]; 
for lp = 2:nsegs;
 g = [g ww^(lp).*ones([1 2*lp-1])]; 
 g2 = [g2 ww^(lp).*ones([1 2*lp])]; 
end
k = [0 cumsum(g) ];
k2 = [0 cumsum(g2) ];
lenk = length(k)-1
lenk2 = length(k2)-2

plot(fk*k(1:lenk),'x');
hold
plot(fk*k(1:lenk),'-');
plot(fk*k2(1:lenk2),'-.');
plot(fk*k2(1:lenk2),'x');
for lp = 2:leaves;
  plot(fk*k2(1:lenk2).*(ww^(lp-1)),'o');
  plot(fk*k2(1:lenk2).*(ww^(lp-1)),':');
  plot(fk*k(1:lenk).*(ww^(lp-1)),'o');
  plot(fk*k(1:lenk).*(ww^(lp-1)),':');
end
hold
axis('image')

