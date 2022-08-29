function f=vshift(vector,indeces,fill)
% Usage ... f=vshift(vector,indeces,fill)
%
% Shifts vector by number of indeces. Select
% fill as the number you want filled at the
% beggining or end, otherwise circular is default.

if nargin<=2,
  %disp(['Filling with data...']);
  fill=[];
end;
vlen=length(vector);

if indeces<0,
  indeces=abs(indeces);
  if isempty(fill),
    pad=vector(vlen-indeces+1:vlen);
  else,
    pad=fill*ones(indeces,1);
  end;
  %size(pad), size(vector),
  f=[pad;vector(1:vlen-indeces)];
elseif indeces>0,
  indeces=abs(indeces);
  if isempty(fill),
    pad=vector(1:indeces);
  else,
    pad=fill*ones(indeces,1);
  end;
  f=[vector(indeces+1:vlen);pad];
else,
  f=vector;
end;

