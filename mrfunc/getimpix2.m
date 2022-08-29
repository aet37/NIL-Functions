function [f,np]=getimpix(map)
% Usage ... [f,np]=getimpix(map)
%
% NOTE: map CAN NOT be transposed!

[tmp1,tmp2]=find(map);
f=[tmp1 tmp2];
np=length(tmp1);

%np=0;
%for m=1:mx, for n=1:my,
%  if (map(m,n)),
%    np=np+1;
%    f(np,:)=[m n];
%  end; end;
%end;

