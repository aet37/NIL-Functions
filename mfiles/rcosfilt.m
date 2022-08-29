function [yy,ff]=rcosfilt(np,fcutoff,fbw,high_flag)
% Usage ... [y,f]=rcosfilt(np,fcutoff,fbw,high_flag)
%
% np = #points
% the vector will be re-translated such that the frequency vector
% ranges from -1 to +1 for the filter design, fcutoff and fbw
% need to be given in these units. default is low_pass (0)

if (nargin<4),
  high_flag=0;
end;

ff=[1:np]-1;
ff=ff-ceil(ff(end)/2);
yy=zeros(size(ff));

ff=2*ff/np;

yy=0.5*(1+sin(pi*(ff-fcutoff)/(2*fbw))).*(ff<=0);
yy=yy+0.5*(1+sin(pi*(ff-fcutoff)/(2*fbw)+pi)).*(ff>0);
yy(find(abs(ff)>(fcutoff+fbw)))=0;
yy(find(abs(ff)<(fcutoff-fbw)))=1;

%yy=yy.^2;

if (high_flag),
  yy=1-yy;
end;

if (nargout==0),
  plot(ff,yy)
  xlabel('Frequency')
  ylabel('Amplitude')
  axis('tight'), grid('on'), fatlines; dofontsize(15);
end;

