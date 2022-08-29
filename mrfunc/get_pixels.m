function [f,np]=get_pixels(map)
% Usage ... [f,np]=get_pixels(map)
% 
% Map must already be binary and NOT transposed
% for accurate pixel location with respect
% to the getdmodtc timecourse extraction function
% or other ALV functions.

[mx,my]=size(map);

np=0;
for m=1:mx, for n=1:my,
  if (map(m,n)),
    np=np+1;
    f(np,:)=[m n];
  end; end;
end;
