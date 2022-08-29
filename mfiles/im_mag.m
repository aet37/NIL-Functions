function y=im_mag(x),
% Usage ... y=im_mag(x),

if (size(x)==4),
  xnew=mean(x,4);
  clear x
end;

tmpim=0;
for mm=1:size(x,3),
  tmpim=tmpim+x(:,:,mm).^2;
end;
y=sqrt(tmpim)/sqrt(size(x,3));

