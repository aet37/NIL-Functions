function f=showpixtc(im,pix,tc,ax)
% Usage ... f=showpixtc(im,pix,tc,ax)

if nargin<4,
  ax=[1 size(im,1) 1 size(im,2)];
end;

if (size(pix,1)~=size(tc,2)),
  error('sizes of pix and tc are not consistent');
end;

n=1;
for m=1:size(pix,1),
  subplot(211)
  show(im_super(im,pixtoim([pix;pix(m,:)],size(im)),.8)')
  axis(ax)
  subplot(212)
  plot(tc(:,m))
  a=input('');
  if (~isempty(a)),
    f(n)=m; n=n+1;
  end;
end;

