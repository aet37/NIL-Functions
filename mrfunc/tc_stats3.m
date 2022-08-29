function f=tc_stats(x,t,range)
% Usage ... f=tc_stats(x,t,range)
%
% This function calculates some of a time series x
% statistics relevant to fMRI. The order of the
% statistics are:
%  (1-2) [mean of range std of range]
%  (3)   [mean/std of x]
%  (4-5) [max of range  index of range]
%  (6-7) [min of range  index of range]
%  (8-9) [fwhm of range in index  time]
%  (10-11) interpolated version of 5,7 (time units)
%  (12)  onset time (10% above)
%  (13)  fwhm est2
%  (14)  time20
%  (15)  time80
%  (16)  onset est 20-80
%  (17)  fwhm est3
%  (18)  time20b
%  (19)  time80b
%  (20)  onset est 20-80b
%  (21)  fwhm est4
%  (22)  mtt
%
% Ex. yout=tc_stats3(data,t,[-2 10]);

myonyval=[0.2 0.8];
mytol=0.01;

if nargin==2,
  if length(t)==2,
    range=t;
    t=[1:length(x)]';
  end;
end;
if nargin==3,
  range=[find(t>=range(1),1) find(t>=range(2),1)];
  x=x(range(1):range(2));
  t=t(range(1):range(2));
end;
if nargin<2,
  t=[1:length(x)];
end;

ts=t(2)-t(1);

f(1)=mean(x);
f(2)=std(x);
f(3)=f(1)/f(2);
[tmp_max1,tmp_maxi1]=max(x);
[tmp_min1,tmp_mini1]=min(x);
f(4)=tmp_max1;
f(5)=t(tmp_maxi1);
f(6)=tmp_min1;
f(7)=t(tmp_mini1);

found=0;
for m=length(x):-1:tmp_maxi1,
  if ((x(m)>0.5*f(4))&(~found)),
    found=1;
    farsidei=m;
  end;
end;
if (~found), farsidei=tmp_maxi1; end;

found=0;
for m=1:tmp_maxi1,
  if ((x(m)>=0.5*f(4))&(~found)),
   found=1;
   nearsidei=m;
  end;
end;
if (~found), nearsidei=tmp_maxi1; end;

if (nearsidei<=1),
  disp('Warning: Changing nearside index (1)');
  nearsidei=nearsidei+1;
end;
if (farsidei>=length(x)),
  disp('Warning: Changing farside index (1)');
  farsidei=farsidei-1;
end;
%[nearsidei farsidei],

tmpm1=x(nearsidei)-x(nearsidei-1);
tmpm1=(x(nearsidei)-0.5*f(4))/tmpm1;
tmpl1=nearsidei-ts*tmpm1;
tmpm2=x(farsidei)-x(farsidei+1);
tmpm2=(x(farsidei)-0.5*f(4))/tmpm2;
tmpl2=farsidei+ts*tmpm2;
f(8)=(farsidei-nearsidei)*ts;
f(9)=(tmpl2-tmpl1);
%f(9)=f(8)+ts*(tmpm1+tmpm2);

ti=[t(1):0.001*ts:t(length(t))];
xi=interp1(t,x,ti,'spline');
[tmpi1,tmpi2]=max(xi);
[tmpi3,tmpi4]=min(xi);
f(10)=ti(tmpi2);
f(11)=ti(tmpi4);
tmpi21=find(xi>(0.5*f(4)));
f(12)=ti(tmpi21(1));
tmpi22=find(xi>=0.5*f(4));
f(13)=ti(tmpi22(end))-ti(tmpi22(1));

tmpi20=find(xi(1:tmpi2)/tmpi1<=myonyval(1));
tmpi80=find(xi(1:tmpi2)/tmpi1<=myonyval(2));
f(14)=ti(tmpi20(end));
f(15)=ti(tmpi80(end));
tmpslp=(myonyval(2)-myonyval(1))/(f(15)-f(14));
tmpb=myonyval(2)-tmpslp*f(15);
f(16)=-tmpb/tmpslp;

tmpi50a=find(xi(tmpi2:-1:1)/tmpi1<=0.5);
tmpi50b=find(xi(tmpi2:end)/tmpi1<=0.5);
f(17)=(tmpi50a(1)+tmpi50b(1))*(ti(2)-ti(1));

tmpi20b=find(((xi(1:tmpi2)/tmpi1)>=(myonyval(1)-mytol))&((xi(1:tmpi2)/tmpi1)<=(myonyval(1)+mytol)));
tmpi80b=find(((xi(1:tmpi2)/tmpi1)>=(myonyval(2)-mytol))&((xi(1:tmpi2)/tmpi1)<=(myonyval(2)+mytol)));
f(18)=ti(round(mean(tmpi20b)));
f(19)=ti(round(mean(tmpi80b)));
tmpslp2=(mean(xi(tmpi80b)/tmpi1)-mean(xi(tmpi20b)/tmpi1))/(f(19)-f(18));
tmpb2=mean(xi(tmpi80b)/tmpi1)-tmpslp2*f(19);
f(20)=-tmpb2/tmpslp2;

tmpi50a2=find((xi(tmpi2:-1:1)/tmpi1<=0.5+mytol)&(xi(tmpi2:-1:1)/tmpi1>=0.5-mytol));
tmpi50b2=find((xi(tmpi2:end)/tmpi1<=0.5+mytol)&(xi(tmpi2:end)/tmpi1>=0.5-mytol));
f(21)=(mean(tmpi50a2)+mean(tmpi50b2))*(ti(2)-ti(1));

f(22)=sum(x(:).*t(:))/sum(x(:));

tmplinet=[tmpi20(end)-round(0.5*(tmpi80(end)-tmpi20(end))):tmpi80(end)+round(0.5*(tmpi80(end)-tmpi20(end)))]*(ti(2)-ti(1))+ti(1);
tmpline=tmpslp*tmplinet+tmpb;
tmpline2=tmpslp2*tmplinet+tmpb2;

%f(16)=
f=f(:);

%[tmpi2 ti(tmpi2)],

if nargout==0,
  %plot(ti,xi,'-',f(10:11),[max(xi) min(xi)],'x')
  figure(1), clf,
  subplot(211), plot(t,x,ti,xi), axis tight, grid on,
  subplot(212), plot(ti,xi/tmpi1,[f(14) f(15) f(16)],[myonyval 0],'o',...
                      ti([tmpi2-tmpi50a(1) tmpi2+tmpi50b(1)]),[0.5 0.5],'x',...
                      [f(18) f(19) f(20)],[mean(xi(tmpi20b)/tmpi1) mean(xi(tmpi80b)/tmpi1) 0],'o',...
                      tmplinet,[tmpline(:) tmpline2(:)],ti([tmpi2-round(mean(tmpi50a2)) tmpi2+round(mean(tmpi50b2))]),[0.5 0.5],'x'),
  axis tight, grid on,  
end;


