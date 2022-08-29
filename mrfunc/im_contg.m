function [f,im_neigh,im_max_neigh2]=im_contg(im,nn,dn)
% Usage ... f=im_contg(image,Nneighbors,Dneighbors)

if nargin<3, dn=1; end;
if nargin<2, nn=1; end;

[xdim,ydim]=size(im);
im_neigh=zeros(size(im));
im_max_neigh=zeros(size(im));
im_max_neigh2=zeros(size(im));

% determine the number of neighbors
for m=1:xdim, for n=1:ydim,
  if im(m,n)~=0,
    n_neigh_sum=0;
    for o=m-dn:m+dn, for p=n-dn:n+dn,
      if ((o>=1)&(o<=xdim)&(p>=1)&(p<=ydim)),
        n_neigh_sum=n_neigh_sum+im(o,p);
      end;
    end; end;
    im_neigh(m,n)=n_neigh_sum;
  end;
end; end;

% propagate the max number of neighbors in an area
% 2-pass algorithm... may still be a bit faulty...
for m=1:xdim, for n=1:ydim,
  if im(m,n)~=0,
    ll=m-dn;
    rr=m+dn;
    tt=n-dn;
    bb=n+dn;
    if (ll<1), ll=1; end;
    if (rr>xdim), rr=xdim; end;
    if (tt<1), tt=1; end;
    if (bb>ydim), bb=ydim; end;
    im_max_neigh(m,n)=max(max(im_neigh(ll:rr,tt:bb)));
  end;
end; end;
for m=xdim:-1:1, for n=ydim:-1:1,
  if im(m,n)~=0,
    ll=m-dn;
    rr=m+dn;
    tt=n-dn;
    bb=n+dn;
    if (ll<1), ll=1; end;
    if (rr>xdim), rr=xdim; end;
    if (tt<1), tt=1; end;
    if (bb>ydim), bb=ydim; end;
    im_max_neigh2(m,n)=max(max(im_max_neigh(ll:rr,tt:bb)));
  end;
end; end;

f=(im_max_neigh2>=nn);

