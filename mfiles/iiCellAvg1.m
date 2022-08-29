function y=iiCellAvg1(data,roi_ii)
% Usage y=iiCellAvg1(data,roi_ii)
%
% Averages items in data over cells entries in roi_ii
% This function assumes the last dimmension is the one to average.

data=squeeze(data);
dsz=size(data);

for mm=1:length(roi_ii),
  if length(dsz)==4,
    y(:,:,:,mm)=mean(data(:,:,:,roi_ii{mm}),4);
  elseif length(dsz)==3,
    y(:,:,mm)=mean(data(:,:,roi_ii{mm}),3);
  else,
    y(:,mm)=mean(data(:,roi_ii{mm}),2);
  end;
end;

