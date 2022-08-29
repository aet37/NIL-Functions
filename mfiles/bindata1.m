function [y,ys,yn,zz]=bindata1(x,bins)
% Usage ... y=bindata1(x,bins)
%
% x is assumed to be a matrix of all the data where the first
% column contains the sorting vector

nbins=length(bins);

y=zeros(nbins,size(x,2)-1);
ys=y;
yn=zeros(nbins,1);

for mm=1:nbins,
  if mm==1,
    tmpbinw=(bins(2)-bins(1))/2;
    tmpii=find(x(:,1)<bins(mm)+tmpbinw);
  elseif mm==nbins,
    tmpbinw=(bins(end)-bins(end-1))/2;
    tmpii=find(x(:,1)>=bins(end)-tmpbinw);
  else,
    tmpbinw1=(bins(mm+1)-bins(mm))/2;
    tmpbinw2=(bins(mm)-bins(mm-1))/2;
    tmpii=find((x(:,1)>=bins(mm)-tmpbinw2)&(x(:,1)<bins(mm)+tmpbinw1));
  end;
  yn(mm)=length(tmpii);
  if yn(mm)>0, 
    xx(mm)=mean(x(tmpii,1),1);
    xs(mm)=std(x(tmpii,1),[],1);
    y(mm,:)=mean(x(tmpii,2:end),1);
    ys(mm,:)=std(x(tmpii,2:end),[],1);
    zz{mm}=x(tmpii,:);
  else,
    xx(mm)=bins(mm);
    zz{mm}=[];
  end;
end;

if nargout==0,
  %clf, subplot(211), plotmsd2(bins,y,ys), subplot(212), plotmsd2(bins,y,ys./yn),
  plotmsd2(bins,y,ys),
elseif nargout==1,
  yy=y; clear y
  y.bins=bins;
  y.y_avg=yy;
  y.y_std=ys;
  y.y_n=yn;
  y.x_avg=xx;
  y.x_std=xs;
  y.y_all=zz;
end;

