function [f]=OIS_corr2(data,reference)
% Usage ... f=OIS_corr2(data,reference)
%
% reference - reference waveform for correlation

% Image-course approach

if length(size(data))>3, data=squeeze(data); end;

if prod(size(reference))==length(reference),
  reference=reference(:);
end;
nref=size(reference,2);

tmpf=zeros([size(data,1) size(data,2) nref]);

sumim=0;
sumref=0;
count=0;
sumnx2=zeros([size(reference,2) 1]); 
sumny2=zeros([size(data,1) size(data,2) nref]);
sumnxy=sumny2; 

%t=clock;
%disp(['Time:']);
%disp(t);
if nref>1, disp(sprintf('Initiating Analysis (%d)...',nref)); end;

meanim=mean(data,3);
meanref=mean(reference,1);

for m=1:size(data,3), for o=1:nref,
  sumnx2(o)=sumnx2(o)+(reference(m,o)-meanref(o)).*(reference(m,o)-meanref(o));
  sumny2(:,:,o)=sumny2(:,:,o)+(data(:,:,m)-meanim).*(data(:,:,m)-meanim);
  sumnxy(:,:,o)=sumnxy(:,:,o)+(reference(m,o)-meanref(o))*(data(:,:,m)-meanim);
end; end;

for o=1:nref,
    den(:,:,o)=(sumnx2(o)^(0.5)).*(sumny2(:,:,o).^(0.5));
end;

f=zeros(size(den));
f(find((den==0)|(abs(den)<1e-6)))=0;
ii=find(abs(den)>=1e-6);
f(ii)=sumnxy(ii)./den(ii);

%clear f ii meanref den


% convert r to t, just in case
%t=f*sqrt(count-1-2)/((1-f.*f).^0.5);

%disp(['Time: ']);
%disp(clock-t);
%disp(['Done...']);

