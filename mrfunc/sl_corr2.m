function f=sl_corr(frootname,slc,reference,ims,info)
% Usage ... f=sl_corr(rootname,slice,reference,im#s,info)
%
% reference - reference waveform for correlation
% im#s - index of images to use

% Image-course approach

if nargin<5,
  info=[64 64];
end;

sumim=0;
sumref=0;
count=0;
sumnx=0; sumny=0; sumnxy=0; sumnx2=0; sumny2=0;

%t=clock;
%disp(['Time:']);
%disp(t);
disp(['Initiating Analysis...']);

if length(ims)==1, ims=[1:ims]; end;

for k=1:length(ims),
  im=getslim(frootname,slc,ims(k),info);
  sumim=sumim+im;
  count=count+1;
end;
meanim=(1/count)*sumim;  %image
meanref=mean(reference); %value
for k=1:length(ims),
  im=getslim(frootname,slc,ims(k),info);
  sumnx2=sumnx2+(reference(k)-meanref).*(reference(k)-meanref);
  sumny2=sumny2+(im-meanim).*(im-meanim);
  sumnxy=sumnxy+(reference(k)-meanref)*(im-meanim);
end;

den=((sumnx2^(0.5))*(sumny2.^(0.5)));

for m=1:info(1), for n=1:info(2),
  if (den(m,n)==0)|(den(m,n)<1e-6),
    f(m,n)=0;
  else,
    f(m,n)=sumnxy(m,n)/den(m,n);
  end;  
end; end;

% convert r to t, just in case
%t=f*sqrt(info(3)-2)/((1-f.*f).^0.5);

%disp(['Time: ']);
%disp(clock-t);
disp(['Done...']);

