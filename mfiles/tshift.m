function f=tshift(t,y,t0,zero_flag)
% Usage ... f=tshift(t,y,t0,zero_flag)

% time shifting function
% it interpolates to calculate the non-index
% positions and then re-interpolate to get the
% index positions
% written by Alberto Vazquez, University of Michigan (2005)

if nargin<4, zero_flag=0; end;

%t=t(:);
%tt=[t;t+t0];
%tt=sort(tt);
%ti=tt(find((tt<=t(length(t)))&(tt>=t(1))));

if (length(t0)>1),
  yi=zeros(size(y));
  for mm=1:length(t0),
    yyi=interp1(t,y,t-t0(mm));
    iout=find(t>(t(end)-t0(mm)));
    inan=find(isnan(yyi));
    if (length(iout)==length(inan)),
      yyi(inan)=y(iout);
    else,
      yyi(find(isnan(yyi)))=mean(y(iout));
    end;
    yi=yi+yyi;
  end;
else,
  yi=interp1(t,y,t-t0);
  iout=find(t>(t(end)-t0));
  inan=find(isnan(yi));
  if (length(iout)==length(inan)),
    yi(inan)=y(iout);
  else,
    yi(find(isnan(yi)))=mean(y(iout));
  end;
end;

if zero_flag,
  zi=find((t-t(1))<t0);
  if ~isempty(zi), yi(zi)=0; end;
end;

f=yi;

