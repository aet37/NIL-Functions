function f=getimpixval(im,locs)
% Usage ... f=getimpixval(im,locs)

f=zeros(size(locs,1),1);

for m=1:length(f),
  f(m)=im(locs(m,1),locs(m,2));
end;

