function f=im_top(im,n)
% Usage ... f=im_top(im,n)
%
% This function returns a binary image of the same dimensions
% as im where the n highest values are set to 1

f=zeros(size(im));
tmpim=im;
immin=min(min(im));

m=0;
done=0;
while(!done),
  [tmp1,tmp2]=find(tmpim==max(max(tmpim)));
  for m=1:length(tmp1),

  end;
end;
