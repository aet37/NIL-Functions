function f=mylmresp(matparm,time,input,kind,normal,num,den)
% Usage ... f=mylmresp(matparm,time,input,kind,normal,num,den)

[mr,mc]=size(matparm);
[ir,ic]=size(input);
[tr,tc]=size(time);

if (ir~=tr),
  error('Invalid input and/or time parameters!');
end;
if (ic>ir),
  error('Input must be columnar!');
end;

tmp=zeros(size(input));
xlen=0;

for m=1:ic,
  if (kind=='p')
    v=mypulse(time,matparm(m,1),matparm(m,2),matparm(m,3));
    xlen=3;
  elseif (kind=='r')
    v=myramp(time,matparm(m,1),matparm(m,2),matparm(m,3),matparm(m,4));
    xlen=4;
  else
    v=mybell5(time,matparm(m,1),matparm(m,2),matparm(m,3));
    xlen=3;
  end;
  if (normal),
    nv=trapz(time,v);   
    v=matparm(m,2).*(v./nv);
  end;
  w=myconv(input(:,m),v);
  if ~exist('den'),
    %if num==[1 2],
    %  numx=[1 -matparm(xlen+1)];
    %  denx=conv([1 -matparm(xlen+2)],[1 -matparm(xlen+3)]);
    %else,
      numx=[matparm(m,xlen+1:xlen+num(1))];
      denx=[matparm(m,xlen+num(1)+1:xlen+num(1)+num(2))];
      numx=[1 numx(1)];
      denx=[1 denx(1) denx(2)];
    %end;
  else,
    numx=num; 
    denx=den;
  end;
  tmp(:,m)=mysol(numx,denx,w,time);
end;
    
f=tmp;

if nargout==0,
  plot(time,tmp);
end;
