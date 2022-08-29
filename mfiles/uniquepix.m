function f=uniquepix(pixlist),
% Usage ... f=uniquepix(pixlist)
% Returns a 0 for non-unique pixels
% and otherwise returns the number
% of pixels in the list.
% Pixels must be in 2 columns!

[pr,pc]=size(pixlist);
if (pc~=2), error('Improper pixel list!'); end;

f=pr;
for n=1:pr
 q=0;
 for o=1:pr,
   if ((pixlist(n,1)==pixlist(o,1))&(pixlist(n,2)==pixlist(o,2))),
     q=q+1;
   end;
 end;
 if (q>1), f=0; end;
end;

