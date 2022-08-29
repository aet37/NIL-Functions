function sl_writeI0Tr(path,slno,nims,imsize,nechs,TEs)
% Usage ... sl_writeI0Tr(path,slno,nims,imsize,nechs,TEs)
% 
% data written as floats or shorts (see code), if in shorts
% then I0 is written as is and Tr is 1e4*Tr

if length(nims)==1, nims=[1:nims]; end;
if path(end)=='i', path=path(1:end-1); myint=1; else, myint=0; end;

for m=1:length(nims),
  disp(sprintf('Calculating I0 and Tr for im# %d and writing',nims(m)));
  for n=1:nechs,
    if (myint),
      data(:,:,n)=getslim([path,'e',int2str(n),'.i'],slno,nims(m),imsize);
    else,
      data(:,:,n)=getslim([path,'e',int2str(n),'.'],slno,nims(m),imsize);
    end;
  end;
  for mm=1:imsize(1), for nn=1:imsize(2),
    for oo=1:nechs, y(oo)=data(mm,nn,oo); end;
    if (mean(y)>50),
      x=polyfit(TEs,log(y),1);
      Tr(mm,nn)=1000*(-1/x(1));
      I0(mm,nn)=exp(x(2));
      if (Tr(mm,nn)<0), I0(mm,nn)=0; Tr(mm,nn)=0; end;
      if (Tr(mm,nn)>100000), I0(mm,nn)=0; Tr(mm,nn)=0; end;
    else,
      I0(mm,nn)=0;
      Tr(mm,nn)=0;
    end;
  end; end;
  %size(I0),
  %show(I0'), pause,
  if (myint),
    if nims(m)>999,
      filename1=sprintf('%sI0.isl%d.%04d',path,slno,nims(m));
      filename2=sprintf('%sTr.isl%d.%04d',path,slno,nims(m));
    else,
      filename1=sprintf('%sI0.isl%d.%03d',path,slno,nims(m));
      filename2=sprintf('%sTr.isl%d.%03d',path,slno,nims(m));
    end;
  else,
    if nims(m)>999,
      filename1=sprintf('%sI0.sl%d.%04d',path,slno,nims(m));
      filename2=sprintf('%sTr.sl%d.%04d',path,slno,nims(m));
    else,
      filename1=sprintf('%sI0.sl%d.%03d',path,slno,nims(m));
      filename2=sprintf('%sTr.sl%d.%03d',path,slno,nims(m));
    end;
  end;
  writeim(filename1,I0,'float');
  writeim(filename2,Tr,'float');
  %writeim(filename1,round(I0));
  %writeim(filename2,round(1e4*Tr));
end;

