function y=myOutlierRm4(x,t,t_new,t_range,std_thr)
% Usage ... y=myOutlierRm4(x,t,t_new,t_range,std_thr)

if nargin<5, std_thr=2.5; end;
dt_new=t_new(2)-t_new(1);
y_new=zeros(length(t_new),size(x,2));

if isempty(t_range), t_range=[t_new(1) t_new(end)]; end;
irange=find((t_new>=t_range(1))&(t_new<t_range(2)));
irange_out=[irange(1)-1 irange(end)+1];

% first pass -- establish line in range
for mm=1:length(t_new),
  tmpi=find((t>=(t_new(mm)-dt_new/2))&(t<(t_new(mm)+dt_new/2)));
  if isempty(tmpi),
    y_new(mm)='NaN';
  else,
    if mm==irange,
      y_new(mm)='NaN';
    else,
      y_new(mm)=mean(x(tmpi));
    end;
  end;
end;
y_new(irange)=interp1(t_new(irange_out),y_new(irange_out),t_new(irange));
dx=diff(x/mean(y_new));

if nargout==0,
  subplot(211),
  plot(t,x,t_new,y_new)
  subplot(212)
  plot(t(1:end-1),dx)
end;

% second pass -- check the derivative
i0=find(t<t_range(1));
dstd=std(dx(i0));
tmpthr=dstd*std_thr;
ikeepd=[];
for mm=irange,
  tmpi=find((t>=(t_new(mm)-dt_new/2))&(t<(t_new(mm)+dt_new/2)));
  if isempty(tmpi),
    y_new(mm)='NaN';
  else,
    tmpi2=find(dx(tmpi)<tmpthr);
    if ~isempty(tmpi2),
      ikeepd=[ikeepd tmpi(tmpi2)];
      y_new(mm)=mean(x(tmpi(tmpi2)));
    end;
  end;
   
end;

% third pass -- intensity check
if length(std_thr)==2,
  i0=find(t<t_range(1));
  i0_new=find(t_new<t_range(1));
  y0std=std(x(i0)-interp1(t_new(i0_new),y_new(i0_new),t(i0)));
  ikeep=[];
  for mm=irange,
    tmpi=find((t>=(t_new(mm)-dt_new/2))&(t<(t_new(mm)+dt_new/2)));
    if isempty(tmpi),
      y_new(mm)='NaN';
    else,
      tmpthr=y_new(mm)+[-1 1]*y_new(mm)*y0std*std_thr(2);
      tmpi2=find((x(tmpi)>=tmpthr(1))&(x(tmpi)<=tmpthr(2)));
      if isempty(tmpi2),
        disp(sprintf('  warning: empty new bin (%d)',mm));
        y_new(mm)='NaN';
      else,
        ikeep=[ikeep tmpi(tmpi2)];
        y_new(mm)=mean(x(tmpi(tmpi2)));
      end;
    end;
  end;
end;

if nargout==0,
  subplot(212)
  plot(t,x,t_new,y_new,t(ikeep),x(ikeep),'o')
end;

