function [c,d]=crchop(a,b,tr,disdaqs,exptime)
% Usage ... [c,d]=crchop(a,b,tr,disdaqs,exptime)
%

b=b(:);

indx1=0;
for m=2:length(b)
  %disp([b(m-1) b(m) disdaqs*tr]);
  if ( ( b(m-1)<=(disdaqs*tr) )&( b(m)>=(disdaqs*tr) ) )
    indx1=m;
    break;
  end;
end;

if (~indx1) indx1=1; disp('Warning: Index not found'); end;
%disp([indx1]);

n=1;
for m=indx1+1:length(b),
   if (b(m)>exptime) break; end;
   if (b(m-1)<=(disdaqs+n)*tr)&(b(m)>=(disdaqs+n)*tr)
     c(n,:)=a(m,:); d(n)=b(m);
     disp([n]);
     n=n+1;
   end;
end;
