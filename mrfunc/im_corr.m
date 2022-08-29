function [f,fst]=sl_corr(ims,reference)
% Usage ... f=sl_corr(rootname,slice,reference,section,info)
%
% reference - reference waveform for correlation

% Image-course approach


sumim=0;
sumref=0;
count=0;
sumnx=0; sumny=0; sumnxy=0; sumnx2=0; sumny2=0;

%t=clock;
%disp(['Time:']);
%disp(t);
disp(['Initiating Analysis...']);

for k=1:size(ims,3),
  sumim=sumim+ims(:,:,k);
  count=count+1;
end;
meanim=(1/count)*sumim;  %image
meanref=mean(reference); %value
for k=1:size(ims,3),
  sumnx2=sumnx2+(reference(k)-meanref).*(reference(k)-meanref);
  sumny2=sumny2+(ims(:,:,k)-meanim).*(ims(:,:,k)-meanim);
  sumnxy=sumnxy+(reference(k)-meanref)*(ims(:,:,k)-meanim);
end;

den=((sumnx2^(0.5))*(sumny2.^(0.5)));
ii=find(den<1e-6);
f=sumnxy./den;

if (~isempty(den)),
  den(ii)=0;
  f(ii)=0;
end;


% convert r to t, just in case
tmap=f*sqrt(size(ims,3)-2)/((1-f.*f).^0.5);

if (nargout==2),
  fst.corr=f;
  fst.tmap=tmap;
  fst.sumx2=sumx2;
  fst.sumy2=sumy2;
  fst.sumxy=sumxy;
  fst.n=size(ims,3);
end;

%disp(['Time: ']);
%disp(clock-t);
disp(['Done...']);

if (nargout==0),
  show(f)
end;

