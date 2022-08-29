function f=tc_stats(x,range,t,type)
% Usage ... f=tc_stats(x,ramge,t,type)
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
%  (12) onset time (10% above)

if nargin<4,
  type=1;
end;
if nargin<3,
  t=[1:length(x)];
end;
if nargin<2,
  range=[1 length(x)];
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
if (farsidei<=1),
  disp('Warning: Changing farside index (1)');
  farsidei=farsidei+1;
end;

tmpm1=x(nearsidei)-x(nearsidei-1);
tmpm1=(x(nearsidei)-0.5*f(4))/tmpm1;
tmpl1=nearsidei-ts*tmpm1;
tmpm2=x(farsidei)-x(farsidei+1);
tmpm2=(x(farsidei)-0.5*f(4))/tmpm2;
tmpl2=farsidei+ts*tmpm2;
f(8)=(farsidei-nearsidei)*ts;
f(9)=(tmpl2-tmpl1);

ti=[t(1):0.001*ts:t(length(t))];
xi=interp1(t,x,ti,'spline');
[tmpi1,tmpi2]=max(xi);
[tmpi3,tmpi4]=min(xi);
f(10)=ti(tmpi2);
f(11)=ti(tmpi4);
tmpi21=find(xi>(0.05*f(4)));
f(12)=ti(tmpi21(1));
tmpi22=find(xi>=0.5*f(4));
f(13)=ti(tmpi22(end))-ti(tmpi22(1));

f=f(:);

%[tmpi2 ti(tmpi2)],

if nargout==0,
  %plot(ti,xi,'-',f(10:11),[max(xi) min(xi)],'x')
  plot(t,x,ti,xi)
end;


