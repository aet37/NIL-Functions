function y=myreshape2(x,parms,rdim,mean_flag)
% Usage ... y=myreshape1(x,parms,dim,mean_flag)
%
% parms=[ntrials nimtr noff]

if nargin<4, mean_flag=1; end;
if nargin<3, rdim=length(size(x)); end;

ntr=parms(1);
nrep=parms(2);
noff=parms(3);

xdim=size(x);
if length(xdim)==2,
  if rdim==1,
    y=reshape(x([1:ntr*nrep]+noff,:),[nrep ntr size(x,2)]);
  else,
    y=reshape(x(:,[1:ntr*nrep]+noff),[size(x,1) nrep ntr]);
  end;
elseif length(xdim)==3,
  if rdim==1,
    y=reshape(x([1:ntr*nrep]+noff,:,:),[ntr nrep size(x,2) size(x,3)]);
  elseif rdim==2,
    y=reshape(x(:,[1:ntr*nrep]+noff,:),[size(x,1) nrep ntr size(x,3)]);
  else,
    y=reshape(x(:,:,[1:ntr*nrep]+noff),[size(x,1) size(x,2) nrep ntr]);
  end;
elseif length(xdim)==4,
  if rdim==1,
    y=reshape(x([1:ntr*nrep]+noff,:,:,:),[nrep ntr size(x,2) size(x,3) size(x,4)]);
  elseif rdim==2,
    y=reshape(x(:,[1:ntr*nrep]+noff,:,:),[size(x,1) nrep ntr size(x,3) size(x,4)]);
  elseif rdim==3,
    y=reshape(x(:,:,[1:ntr*nrep]+noff,:),[size(x,1) size(x,2) nrep ntrsize(x,4)]);
  else,
    y=reshape(x(:,:,:,[1:ntr*nrep]+noff),[size(x,1) size(x,2) size(x,3) nrep ntr]);
  end;
elseif length(xdim)==5,

end;

if mean_flag,
  y=squeeze(mean(y,rdim+1));
end;

