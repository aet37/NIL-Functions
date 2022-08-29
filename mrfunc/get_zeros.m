function [f,g,h,zer]=get_zeros(filename,ps,nphases,npmult,spirals,slc,nframes,nzpe)
% Usage ... [det_zeros,zeros,axis]=get_zeros(filename,ps,nphases,npmult,spirals,slc,nframes,nzpe)
%
% Returns the detrended zeros (real and imaginary parts)
% Slice must contain two arguments [total#slcs slicetoget]

if strcmp(ps,'sf9'),
  zer=read_zeros(filename,'sf9',nphases,npmult,spirals,slc(1),nframes);
  if rem(slc(2),2), %odd slice
    slc(2)=slc(2)-floor(slc(2)/2);
  else, %even slice
    slc(2)=ceil(slc(1)/(2*4))+slc(2)/2;
  end;
  imperslc=nphases*npmult;
  data=zer((slc(2)-1)*spirals*imperslc+1:slc(2)*spirals*imperslc,:);
elseif strcmp(ps,'sf3d'),
  zer=read_zeros(filename,'sf3d',nphases,npmult,spirals,slc(1),nframes,nzpe);
  imperphs=nphases*npmult;
  data=zer((slc(2)-1)*spirals+1:slc(2)*spirals,:);
  for m=2:imperphs,
    tmploc=(m-1)*nzpe*spirals+(slc(2)-1)*spirals;
    data=[data;zer(tmploc+1:tmploc+spirals,:)]; 
  end;
elseif strcmp(ps,'ros'),
  disp('Rosette acquisition...');
  zer=read_zeros(filename,'ros',nphases,npmult,spirals,slc(1),nframes);
  if rem(slc(2),2), %odd slice
    slc(2)=slc(2)-floor(slc(2)/2);
  else, %even slice
    slc(2)=ceil(slc(1)/(2*4))+slc(2)/2;
  end;
  imperslc=nphases*npmult;
  data=zer((slc(2)-1)*spirals*imperslc+1:slc(2)*spirals*imperslc,:);
end;
   

sig = data(:,1) + i*(data(:,2));
axis_sig = [1:length(sig)];

p = polyfit(axis_sig,sig',1);	% trying to remove linear trend
p2 = [p(1) 0];

f = conj(sig' -conj(polyval(p2,axis_sig))); 
g = sig;
h = axis_sig;
