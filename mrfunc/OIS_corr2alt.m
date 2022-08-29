function [f]=OIS_corr2(data,reference,rs_flag)
% Usage ... f=OIS_corr2(data,reference,rs_flag)
%
% reference - reference waveform for correlation

% Image-course approach


if nargin<3, rs_flag=0; end;
if rs_flag,
  dsize=size(data);
  disp('Vectorizing...');
  data=reshape(data,dsize(1)*dsize(2),dsize(3)); 
end;

sumnxy=0;
sumnx2=0;
sumny2=0;

%t=clock;
%disp(['Time:']);
%disp(t);
disp(['Initiating Analysis...']);


if length(size(data))==3,
  meanim=mean(data,3);
  meanref=mean(reference);
  disp('  classic...'),
  for m=1:size(data,3),
    sumnx2=sumnx2+(reference(m)-meanref).*(reference(m)-meanref);
    sumny2=sumny2+(data(:,:,m)-meanim).*(data(:,:,m)-meanim);
    sumnxy=sumnxy+(reference(m)-meanref)*(data(:,:,m)-meanim);
  end;
else,
  disp('  vectorized...')
  sumnx2=sum((reference(:)-mean(reference)).^2);
  sumny2=sum((data-mean(data,2)*ones(1,size(data,2))).^2,2);
  sumnxy=sum((ones(size(data,1),1)*((reference(:)-mean(reference))')).*(data-mean(data,2)*ones(1,size(data,2))),2);
end;

if rs_flag,
  sumny2=reshape(sumny2,dsize(1),dsize(2));
  sumnxy=reshape(sumnxy,dsize(1),dsize(2));
end;

den=((sumnx2^(0.5))*(sumny2.^(0.5)));

f=zeros(size(den));
f(find((den==0)|(abs(den)<1e-6)))=0;
ii=find(abs(den)>=1e-6);
f(ii)=sumnxy(ii)./den(ii);


% convert r to t, just in case
%t=f*sqrt(length(reference)-1-2)/((1-f.*f).^0.5);

%disp(['Time: ']);
%disp(clock-t);
disp(['Done...']);

