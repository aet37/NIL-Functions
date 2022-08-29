function sl_writeCBV(slpath,slno,nims,imsize,norm)
% Usage ... sl_writeCBV(slpath,slno,nims,imsize,norm)
%
% Recall I0/Tr data saved as float so need the flag below...
%  add a 1 in imsize(4) (e.g. [64 64 2 1])

% account for the ffact that data read in is in FLOAT form for now...
if length(imsize)==2, imsize=[imsize 2 1]; end;
if length(imsize)==3, imsize(4)=1; end;

SCALEF=10;

disp('Reading slice data...');
for m=2:2:nims,
  data1(:,:,m-1)=getslim([slpath,'I0.'],slno,m-1,imsize);
  data2(:,:,m)=getslim([slpath,'I0.'],slno,m,imsize);
end;

for m=2:2:nims,
  if m==nims,
    data1(:,:,m)=0.5*data1(:,:,m-1)+0.5*data1(:,:,1);
  else,
    data1(:,:,m)=0.5*data1(:,:,m-1)+0.5*data1(:,:,m+1);
  end;
end;
for m=1:2:nims,
  if m==1,
    data2(:,:,m)=0.5*data2(:,:,nims)+0.5*data2(:,:,m+1);
  else,
    data2(:,:,m)=0.5*data2(:,:,m-1)+0.5*data2(:,:,m+1);
  end;
end;

%subplot(211)
%show(data1(:,:,10)')
%subplot(212)
%show(data1(:,:,10)'-data2(:,:,10)')
%pause,

if (norm),
  for m=1:nims, 
    for mm=1:imsize(1), for nn=1:imsize(2),
      if data1(mm,nn,m)~=0,
        data1(mm,nn,m)=(data1(mm,nn,m)-data2(mm,nn,m))./data1(mm,nn,m);
      end;
    end; end;
  end;
else,
  for m=1:nims, 
    data1(:,:,m)=(data1(:,:,m)-data2(:,:,m));
  end;
end;

disp('Writing slice data...');
for m=1:nims,
  fname=sprintf('pcbv.sl%d.%03d',slno,m);
  %writeim(fname,round(SCALEF*squeeze(data1(:,:,m)-data2(:,:,m))));
  writeim(fname,data1(:,:,m),'float');
end;

clear all

