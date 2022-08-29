function f=pixlist_extract(pix_list,data,new_list)
% Usage ... f=pixlist_extract(pix_list,data,new_list)
%
% The data must be organized in columns.
% The pixlist must be organized in rows.

[datar,datac]=size(data);
[pixno]=size(pix_list,1);
[newpixno]=size(new_list,1);

if size(new_list,2)==1,

if (datac~=pixno) error('Improper argument organization!'); end;

f=zeros([datar newpixno]);
for m=1:newpixno,
  found=0;
  for n=1:pixno,
    if (pix_list(n,1)==new_list(m,1))&(pix_list(n,2)==new_list(m,2)),
      f(:,m)=data(:,n);
      found=1;
    end;
  end;
  if ~found,
     disp(['Warning: new_list location ',int2str(new_list(m,1)),' ',int2str(new_list(m,2)),' not found on pix_list...']);
  end;
end;

else,

if (length(new_list)==size(pix_list,1))&(length(new_list)==size(data,2))

cnt=1;
for m=1:length(new_list),
  if (new_list(m)), f(cnt)=data(:,m); cnt=cnt+1; end;
end;

else, error('the length of newlist must equal the columns of data and the rows of pixlist!');

end;

end;
