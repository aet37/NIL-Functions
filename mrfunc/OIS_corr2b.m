function [f]=OIS_corr2b(data,reference,t_flag)
% Usage ... f=OIS_corr2b(data,reference,t_flag)
%
% reference - reference waveforms for correlation in columns

% Image-course approach

verbose_flag=0;

if nargin<3, t_flag=''; end;
if isempty(t_flag), t_flag=0; end;

sumim=0;
sumref=0;
count=0;
sumnx=0; 
sumny=0; 
sumnxy=zeros(size(data,1),size(data,2),size(reference,2));
sumnx2=0; 
sumny2=0;

clk=clock;
disp(['Initiating Analysis...']);

meanim=mean(data,3);
meanref=squeeze(mean(ref,1));

for m=1:size(data,3),
  sumny2=sumny2+(data(:,:,m)-meanim).*(data(:,:,m)-meanim);
  for n=1:size(reference,2),      
    sumnx2(n)=sumnx2(n)+(reference(m,n)-meanref(n)).*(reference(m,n)-meanref(n));
    sumnxy(:,:,n)=sumnxy+(reference(m,n)-meanref(n))*(data(:,:,m)-meanim);
  end;
end;

den=((sumnx2^(0.5))*(sumny2.^(0.5)));
ii=find(abs(den)>=1e-6);

for n=1:size(reference,2),
  tmpf=zeros(size(den));
  tmpf(find((den==0)|(abs(den)<1e-6)))=0;
  tmpsumnxy=sumnxy(:,:,n);
  tmpf(ii)=tmpsumnxy(ii)./den(ii);
  f(:,:,n)=tmpf;
end;


if t_flag,
% convert r to t, just in case
%t=f*sqrt(count-1-2)/((1-f.*f).^0.5);
f=f*sqrt(count-1-2)/((1-f.*f).^0.5);
end;

if verbose_flag,
  disp(['Time: ']);
  disp(clock-clk);
end;
disp(['Done...']);

