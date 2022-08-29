function [p1,p2]=cubelinesurfpts(cubedims,thetas,initialps)
% Usage ... [p1,p2]=cubelinesurfpts(cubedims,thetaxyz,initialps)
%
% Returns the 3d surface points which touch a line with angles
% surface points which touch a line with angles theta (x-y) and
% theta (x-y) and phi (xy-z) and translations (xyz). The cube 
% is assumed to be centered in the origin.

% Translations are not yet implemented in this function!!!

xdim=cubedims(1);
ydim=cubedims(2);
zdim=cubedims(3);

ct=[0 0 0];
p1=[0 0 0];
p2=[0 0 0];

%if (theta<atan(ydim/xdim)),
%  p1(1)=-xdim/2;
%  p2(1)=+xdim/2;
%  p1(2)=-xdim/2*tan(theta);
%  p2(2)=+xdim/2*tan(theta);
%else,
%  if (theta==pi/2),
%    p1(1)=0.0;
%    p2(1)=0.0;
%  else,
%    p1(1)=-ydim/2*(1/tan(theta));
%    p2(1)=+ydim/2*(1/tan(theta));
%  end;
%  p1(2)=-ydim/2;
%  p2(2)=+ydim/2;
%end;
%
%Lxy=0.5*(sum((p1-p2).^2)).^(1/2);
%
%if (phi<atan(zdim/Lxy)),
%  p1(3)=-zdim/2*tan(phi);
%  p2(3)=+zdim/2*tan(phi);
%else,
%  p1(3)=-zdim/2;
%  p2(3)=+zdim/2;
%  if (phi==pi/2),
%    Lxyp=0.0;
%  else,
%    Lxyp=+zdim/2*(1/tan(phi));
%  end;
%  p1(1)=-Lxyp*sin(theta);
%  p2(1)=+Lxyp*sin(theta);
%  p1(2)=-Lxyp*cos(theta);
%  p2(2)=+Lxyp*cos(theta);
%end;

% Corroboration of the angles with rot
initial1=initialps(1,:)';
initial2=initialps(2,:)';
final1=rot(initial1,[1 2 3],thetas)';
final2=rot(initial2,[1 2 3],thetas)';
p1=final1;
p2=final2;

% the difference between p1 and p2 should be the magnitude only
% not the direction

