function [f,g]=mymedp(plant,time,input,kind,normal,parm,order)
% Usage ... [f,g]=mymedp(plant,time,input,kind,normal,parm,order)
% g contains indexes sorted

[mr,mc]=size(plant);
halfind=fix(mr/2);
remind=rem(mr,2);
mypoles=plant(:,mc-order(2)+1:mc);
for n=1:mr, 
  poles(n,:)=roots([1 mypoles(n,:)])';
end;
[sp,is]=sort(mean(poles')');

if ~remind,
  tmpnum1=[1 plant(is(halfind),1)]; tmpden1=[1 plant(is(halfind),2) plant(is(halfind),3)];
  tmp(:,1)=mylmresp([parm],time,input,kind,normal,tmpnum1,tmpden1);
  tmpnum2=[1 plant(is(halfind+1),1)]; tmpden2=[1 plant(is(halfind+1),2) plant(is(halfind+1),3)];
  tmp(:,2)=mylmresp([parm],time,input,kind,normal,tmpnum2,tmpden2);
  %f=mean(tmp')';
  tmp(:,3)=mean(tmp')';
  %g=[is(halfind) is(halfind+1)];

  mz=mean([plant(is(halfind),1);plant(is(halfind+1),1)]);
  mp=mean([plant(is(halfind),2:3);plant(is(halfind+1),2:3)]);
  tmpnum3=[1 mz(1)]; tmpden3=[1 mp(1) mp(2)];
  tmp(:,4)=mylmresp([parm],time,input,kind,normal,tmpnum3,tmpden3);

  mzp=mean([roots(tmpnum1);roots(tmpnum2)])
  mpp=mean([roots(tmpden1)';roots(tmpden2)'])
  if (imag(mpp(1))|imag(mpp(2)))&(~((real(mpp(1))==real(mpp(2)))&(imag(mpp(1))==-imag(mpp(2))))),
    disp(['Uneven poles for averaging']);
    m1=mean(roots(tmpden1));
    m2=mean(roots(tmpden2));
    m3=mean([m1;m2]);
    m6=imag(mpp(1))
    mpp=[m3+i*m6 m3-i*m6]
  end;
  tmpnum4=[1 -mzp(1)]; tmpden4=conv([1 -mpp(1)],[1 -mpp(2)]);
  tmp(:,5)=mylmresp([parm],time,input,kind,normal,tmpnum4,tmpden4);
  f=tmpnum4;
  g=tmpden4;
else,
  tmpnum=[1 plant(is(halfind+1),1)]; tmpden=[1 plant(is(halfind+1),2) plant(is(halfind+1),3)];
  tmp=mylmresp([parm],time,input,kind,normal,tmpnum,tmpden);
  %f=tmp;
  %g=is(halfind+1);
  f=tmpnum;
  g=tmpden;
end;

if nargout==0,
  plot(time,tmp);
  xlabel(int2str(g));
  disp([plant,poles])
  disp([is])
end;
