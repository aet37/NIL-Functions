function y=xshift(x,ii,zero_flag)
% Usage ... y=xshift(x,i,zero_flag)
% 
% x must be a vector, i can be a scalar or vector

%if nargin<3, dim=[]; end;
if nargin<3, zero_flag=0; end;

do_many=1;
if prod(size(x))==length(x), do_many=0; end;

if do_many,
  for nn=1:size(x,2), for mm=1:length(ii),
    y(:,nn,mm)=circshift(x(:,nn),ii(mm));
    if zero_flag,
      if ii(mm)<0, y(end+ii(mm)+1:end,nn,mm)=0; elseif ii(mm)>0, y(1:ii(mm),nn,mm)=0; end;
    end;
  end; end;
else,
  for mm=1:length(ii),
    y(:,mm)=circshift(x(:),ii(mm));
    if zero_flag,
      if ii(mm)<0, y(end+ii(mm)+1:end,mm)=0; elseif ii(mm)>0, y(1:ii(mm),mm)=0; end;
    end;
  end;
end;

if nargout==0,
  clf, plot(y), axis tight, grid on,
end
