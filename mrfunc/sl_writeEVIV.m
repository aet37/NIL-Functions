function sl_writeEVIV(slpath,slno,nims,imsize,evout)
% Usage ... sl_writeEVIV(slpath,slno,nims,imsize,evout)
%
% Data written as floats

thr_br=70;

if nargin<5, evout=1; end;
if evout==2, evout=0; end;

% read the mag and phs data (non-diff case first)
disp('Loading data...');
for m=1:nims,
  data_mag(:,:,m)=getslim(slpath,slno,m,imsize);
  data_phs(:,:,m)=getslim(slpath,slno,m,imsize,'phs')/1000;
  data_phs(:,:,m)=unwrap(data_phs(:,:,m));
end;

% now to estimate
disp('Estimating...');
for m=1:imsize(1), for n=1:imsize(2),
  if (mean(data_mag(m,n,:))>thr_br),
    x=polyfit(data_phs(m,n,:),data_mag(m,n,:),1);
    data_est(m,n,:)=polyval(x,squeeze(data_phs(m,n,:)));
    A(m,n)=x(1);
    B(m,n)=x(2);
    %data_new(m,n,:)=(data_mag(m,n,:)-data_est(m,n,:));
    data_new(m,n,:)=(data_mag(m,n,:)-data_est(m,n,:))+mean(data_mag(m,n,:));
    SSE(m,n)=sum((data_mag(m,n,:)-data_new(m,n,:)).^2);
  else,
    data_est(m,n,:)=zeros([1 nims]);
    A(m,n)=0;
    B(m,n)=0;
    SSE(m,n)=0;
    data_new(m,n,:)=data_mag(m,n,:);
  end;
end; end;

% write data
if (evout),
  % this mean write new data
  for m=1:nims,
    fname=sprintf('%snew.sl%d.%03d',slpath,slno,m);
    writeim(fname,squeeze(data_new(:,:,m)),'float');
  end;
else,
  % this mean write estimate
  for m=1:nims,
    fname=sprintf('%sest.sl%d.%03d',slpath,slno,m);
    writeim(fname,squeeze(data_est(:,:,m)),'float');
  end;
end;
fname=sprintf('%ssl%d.eviv.sse',slpath,slno);
writeim(fname,SSE,'float');

clear all

