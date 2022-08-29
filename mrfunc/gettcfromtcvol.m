function y=gettcfromtcvol(tcvol,pix)
% Usage ... y=gettcfromtcvol(tcvol,pix)
%

y=zeros(size(pix,1),size(tcvol,3));

for mm=1:size(pix,1),
  y(mm,:)=squeeze(tcvol(pix(mm,1),pix(mm,2),:)).';
end;

