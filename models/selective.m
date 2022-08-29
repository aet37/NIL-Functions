% all times in ms
%fid = fopen('b1.txt');
%times = fscanf(fid,'%g',[8 100]);
s=randn(3,3,2500);
l = zeros([3 2500]);
n=3;
% finding average signal
for i=1:3
	for j=1:3
		l(i,:)=l(i,:)+squeeze(s(i,j,:))';
	end
	y(i,:)=l(i,:)./n;	
end    

%this is for variance
m = zeros([3 2500]);
si = zeros([3 2500]);
for i=1:3
	for j=1:3
			m(j,:)=m(j,:)+((squeeze(s(i,j,:))'-y(i,:)).^2);
	end	
	si(i,:)=m(j,:)./(n-1);	
end    

% Finding Ybar
y1(i)=0;
si1(i)=0;
for i=1:3
		y1(i)=sum(y(i,:)');
		si1(i)=sum(si(i,:)');
		ybar(i)=y1(i)./2500;
		sibar(i)=sqrt(si1(i)./2500);
end

% Finding Hbar
h1(i)=0;
for i=1:3
	for k=1:2500
		a=(k-si(i,k))./1.25;
		b=exp(a);
		h(i,k)=(((k-2500)./1250).^2).*(b);
	end	
	h1(i)=sum(h(i,:)');
	hbar(i)=h1(i)./2500;
end

% Q test
num(i) = 0;
den1(i) = 0;
for i=1:3
	for k=1:2500
		num(i)=num(i)+((y(i,k)-ybar(i)).*(h(i,k)-hbar(i)));
		den1(i)=den1(i)+(h(i,k)-hbar(i));
	end
	den(i)=sqrt(den1(i));
	q(i)=num(i)./(sibar(i).*den(i));
end	
