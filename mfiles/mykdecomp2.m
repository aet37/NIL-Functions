function [y,ys]=mykdecomp2(tmpdata,nk,tmpmask,tmpname)
% Usage ... [k,ks]=mykdecomp2(stk,nk,mask,sname)

small_flag=1;		% this has been moved in the mykmeans function now

tmpmaski=find(tmpmask);
tmpdataR=reshape(tmpdata,size(tmpdata,1)*size(tmpdata,2),size(tmpdata,3));
tmpchk=zeros(size(tmpdata(:,:,1)));
tmpchk(tmpmaski)=mean(tmpdataR(tmpmaski,:),2);
tmpk=mykmeans(tmpdataR(tmpmaski,:)',nk,tmpmaski);
if small_flag,
  if length(tmpk)==1,
    tmpk=rmfield(tmpk,'xc');
  end;
end;
if length(tmpk)==1,
  tmpkim=zeros(size(tmpdata(:,:,1)));
  tmpkim(tmpmaski)=tmpk.cli;
  tmpks=mykmeans_sup(tmpk,tmpdata,tmpmaski,2.0);
  tmpxf=fft(tmpk.xm-ones(size(tmpk.xm,1),1)*mean(tmpk.xm,1));
  tmpk.mask=tmpmask;
  tmpk.kim=tmpkim;
  tmpk.xmf=tmpxf;
else,
  tmpkim=zeros(size(tmpdata,1),size(tmpdata,2),length(tmpk));
  for mm=1:length(tmpk),
    tmpkim1=zeros(size(tmpdata,1),size(tmpdata,2));
    tmpkim1(tmpmaski)=tmpk{mm}.cli;
    tmpkim(:,:,mm)=tmpkim1;
    tmpxf=fft(tmpk{mm}.xm-ones(size(tmpk{mm}.xm,1),1)*mean(tmpk{mm}.xm,1));
    tmpk{mm}.mask=tmpmask;
    tmpk{mm}.kim=tmpkim1;
    tmpk{mm}.xmf=tmpxf;
  end;
  tmpks=mykmeans_sup(tmpk,tmpdata,tmpmaski,2.0);
end;
clear tmpdataR



y=tmpk;
ys=tmpks;

if nargout==1,
  if length(tmpk)>1,
    for mm=1:length(tmpks),
      if small_flag,
        y{mm}.rim=tmpks{mm}.rim;
      else,
        y{mm}.ks=tmpks;
      end;
    end;
  else,
    if small_flag,
      y.rim=tmpks.rim;
    else,
      y.ks=tmpks;
    end;
  end;
end;

if exist('tmpname'),
  if length(y)==1. 
    y.note=tmpname;
  else,
    for mm=1:length(y), y{mm}.note=tmpname; end;
  end;
end;

if exist('tmpname')&(length(tmpk)==1),
  close all
  
  figure(1)
  subplot(211)
  show(mean(tmpdata,3))
  title(sprintf('%s Avg Image',tmpname))
  axis('off'), grid('off'),
  subplot(212)
  show(im_super(mean(tmpdata,3),tmpmask,0.5))
  title('Brain Mask (Seeds)'),
  axis('off'), grid('off'),
  setpapersize([5 10])
  
  figure(2)
  imagesc(tmpkim)
  title(sprintf('%s K-Means Clusters (k=%d)',tmpname,size(tmpk.xm,2)))
  axis('image'), colormap(jet),
  
  figure(3)
  tile3d(tmpks.rim,[0 1],1)
  title(sprintf('%s Cluster Correlations (k=%d)',tmpname,size(tmpk.xm,2)))
  
  figure(4)
  subplot(211)
  plot([0:size(tmpdata,3)-1],(tmpk.xm./(ones(size(tmpk.xm,1),1)*mean(tmpk.xm,1))-1)*100)
  xlabel('Index #'), ylabel('Signal (%)'), title('Avg Cluster Time Series'),
  axis('tight'), grid('on'), dofontsize(15);
  subplot(212)
  ff=[0:size(tmpdata,3)-1];
  plot(ff,abs(tmpxf))
  xlabel('Frequency Index#'), ylabel('Magnitude (a.u.)'),
  axis('tight'), grid('on'), dofontsize(15);
  %tmpax=axis; axis([0 0.1 0 tmpax(4)]); 
end;

