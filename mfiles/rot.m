function xx=rot(x,rotaxis,angle)
% Usage ... xx=rot(x,rotaxis,angle)
%
% Rotates the vector x about the axis rotaxis
% by an amount angle . Note that the angle is
% the angle with respect to the rotation axis
% (rotaxis: 1-x, 2-y, 3-z)

% Remember the axis of rotation is NOT the direction of
% rotation! For example, rot([1 0 0]',1,pi) = [1 0 0]' but
% rot([1 0 0]',2,pi/2) = [0 0 1]'

if length(rotaxis)==1,

  Rx=[1 0 0;0 cos(angle) sin(angle);0 -sin(angle) cos(angle)];
  Ry=[cos(angle) 0 -sin(angle);0 1 0;sin(angle) 0 cos(angle)];
  Rz=[cos(angle) sin(angle) 0;-sin(angle) cos(angle) 0;0 0 1];

  if rotaxis==1,
    xx=Rx*x;
  elseif rotaxis==2,
    xx=Ry*x;
  elseif rotaxis==3,
    xx=Rz*x;
  else,
    xx=x;
  end;

else,

  xx=x;
  for m=1:length(rotaxis),
    Rx=[1 0 0;0 cos(angle(m)) sin(angle(m));0 -sin(angle(m)) cos(angle(m))];
    Ry=[cos(angle(m)) 0 -sin(angle(m));0 1 0;sin(angle(m)) 0 cos(angle(m))];
    Rz=[cos(angle(m)) sin(angle(m)) 0;-sin(angle(m)) cos(angle(m)) 0;0 0 1];
    if rotaxis(m)==1,
      xx=Rx*xx;
    elseif rotaxis(m)==2,
      xx=Ry*xx;
    elseif rotaxis(m)==3,
      xx=Rz*xx;
    end;
  end;

end;

