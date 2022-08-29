function f=my_sort(list,xlist)
% Usage ... f=my_sort(list,xlist)
% 
% Sorts the list and eliminates repeated elements
% to satisfy uniqueness and also eliminates elements
% outside the range of the xlist

if ~exist('xlist'),
  xlist=[1 max(list)];
end;

list2=sort(list);
cnt=1; start=0;
while(1),
  if list2(cnt)>=xlist(1),
    start=cnt; break;
  end;
  if cnt==length(xlist), error('Invalid list!'); end;
  cnt=cnt+1;
end;

tmp=list2(start); cnt=1;
for m=start+1:length(list2),
  if (list2(m-1)~=list2(m)),
    if (list2(m)<=xlist(length(xlist))),
      cnt=cnt+1;
      tmp(cnt)=list2(m);
    end;
  end;
end;

f=tmp;
