function [f,np]=getimpix(map)
% Usage ... [f,np]=getimpix(map)
%
% NOTE: map CAN NOT be transposed!

[mx,my]=size(map);

np=0;
for m=1:mx, for n=1:my,
  if (map(m,n)),
    np=np+1;
    f(np,:)=[m n];
  end; end;
end;

