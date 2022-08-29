function [y,x]=mysol(up,down,inp,time,xi)
% Usage ... [y,x]=mysol(up,down,inp,time,xi)
%

[a,b,c,d]=tf2ss(up,down);

[ar,ac]=size(a);
[br,bc]=size(b);
[cr,cc]=size(c);
[dr,dc]=size(d);
[ur,uc]=size(inp);
tlen=length(time);

if (ur<uc), inp=inp'; [ur,uc]=size(inp); end;

% Assume zero IC's
if (nargin==4), xi=zeros(ac,1); end;

fs=time(2)-time(1);

d_inp= inp(2:ur,:) - inp(1:ur-1,:);
f_inp= find(d_inp~=0);
inp_s= find(diff(f_inp)==1);
f_hld= (length(inp_s)>0);
if (f_hld),
  % Temporary change to avoid SS manipulation
  [up2,down2]=ss2tf(zeros(dc),eye(dc),eye(dc),zeros(dc));
  [a,b,c,d]=tf2ss(conv(up,up2),conv(down,down2));
  xi= [zeros(dc,1);xi(:)]+(b*inp(1,:).');
  inp(1:ur-1,:)= d_inp/fs;
  inp(ur,:)=inp(ur-1,:);
end;

[ar,ac]=size(a);
[br,bc]=size(b);
tmp=expm([ [a b]*fs; zeros(bc,ac+bc) ]);
biga=tmp(1:ac,1:ac);
bigb=tmp(1:ac,ac+1:ac+bc);

%for i=1:ur,
%  tmpx(:,i)=xi;
%  xi= biga*xi + bigb*inp(:,i);
%end;
%tmpx=tmpx.';

tmpx=ltitr(biga,bigb,inp,xi);
tmpy= tmpx*c.' + inp*d.';

if (nargout==0),
  plot(time,tmpy,time,zeros(size(time)));
end;

if (nargout==2), if (f_hld), tmpx=tmpx(:,1+dc:ac+dc); end; end;

x=tmpx;
y=tmpy;