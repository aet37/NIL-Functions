function [y,herr1,hmin1]=chkOISseq1(data,nseq,refims)
% Usage ... y=chkOISseq1(data,nseq,refims)

if nargin<3, refims=data(:,:,1:nseq); end;

nbins=50;
for mm=1:nseq,
  tmpdata=refims(1:end/2,1:end/2,mm);
  tmphist=hist(tmpdata(:),nbins);
  refhist(:,mm)=tmphist(:);
end;

for mm=1:size(data,3),
  tmpdata=data(1:end/2,1:end/2,mm);
  tmphist=hist(tmpdata(:),nbins); 
  herr1(mm,:)=mean((tmphist(:)*ones(1,nseq)-refhist).^2);
end;

[hmin1,hmin1i]=min(herr1,[],2);
y=hmin1i;

