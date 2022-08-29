function y=inoti(i1,i2,inflag,nanflag)
% Usage ... y=inoti(i1,i2,inflag,nanflag)
%
% Return the elements in i2 that are not in i1
% if inflag is added, it will return the location of i1 entries in i2
% if the entry does not exist, nan will be returned, or zero
%
% Ex.
%  inoti([4 5 8],[1:10])
%  inoti([5 9 20],[1:2:21],1)

do_in=0;
do_nan=1;
if exist('inflag','var'), do_in=1; end;
if exist('nanflag','var'), do_nan=0; end;

if do_in,
  cnt=0;
  for mm=1:length(i1),
    tmpi=find(i1(mm)==i2);
    if ~isempty(tmpi),
      cnt=cnt+1;
      y(cnt)=tmpi;
    else,
      if do_nan,
        cnt=cnt+1;
        y(cnt)=nan;
      else,
        cnt=cnt+1;
        y(cnt)=0;
      end;
    end;
  end;
else,
  cnt=0;
  for mm=1:length(i2),
    tmpi=find(i2(mm)==i1);
    if isempty(tmpi), cnt=cnt+1; y(cnt)=mm; end;
  end;
end;

