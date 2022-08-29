function f=analyze_corr2(frootname,reference,section,info)
% Usage ... f=analyze_corr2(rootname,reference,section,info)
%
% reference - reference waveform for correlation
% section- sections of the timecourse to regress only in images!

% Image-course approach

if nargin<4,
  info=[64 64 50];
end;

im=0;
sumim=0;
sumref=0;
count=0;
sumnx=0; sumny=0; sumnxy=0; sumnx2=0; sumny2=0;

%t=clock;
%disp(['Time:']);
%disp(t);
disp(['Initiating Analysis...']);

if length(section)>=3,
  disp(['Doing sections...']);
  nsections=length(section)/2;
  for k=1:nsections,
    for m=section(2*k-1):section(2*k),
      im=getanalyzevol(frootname,m,info);
      sumim=sumim+im;
      sumref=sumref+reference(m);
      count=count+1;
    end;
  end;
  meanim=(1/count)*sumim;  %image
  meanref=(1/count)*sumref; %value
  count=1;
  for k=1:nsections,
    disp(['Section ',int2str(k)]);
    for m=section(2*k-1):section(2*k),
      im=getanalyzevol(frootname,m,info);
      sumnx2=sumnx2+(reference(m)-meanref).*(reference(m)-meanref);
      sumny2=sumny2+(im-meanim).*(im-meanim);
      sumnxy=sumnxy+(reference(m)-meanref)*(im-meanim);
      count=count+1;
    end;
  end;
  disp(['Sections Done...']);
else,
  if length(section)==1, section(2)=section(1); section(1)=1; end;
  for k=section(1):section(2),
    im=getanalyzevol(frootname,k,info);
    sumim=sumim+im;
    count=count+1;
  end;
  meanim=(1/count)*sumim;  %image
  meanref=mean(reference); %value
  for k=section(1):section(2),
    im=getanalyzevol(frootname,k,info);
    sumnx2=sumnx2+(reference(k)-meanref).*(reference(k)-meanref);
    sumny2=sumny2+(im-meanim).*(im-meanim);
    sumnxy=sumnxy+(reference(k)-meanref)*(im-meanim);
  end;
end;

den=((sumnx2^(0.5))*(sumny2.^(0.5)));

for o=1:info(3),
for m=1:info(1), for n=1:info(2),
  if (den(m,n,o)==0)|(den(m,n,o)<1e-6),
    f(m,n,o)=0;
  else,
    f(m,n,o)=sumnxy(m,n,o)/den(m,n,o);
  end;  
end; end;
end;

%disp(['Time: ']);
%disp(clock-t);
disp(['Done...']);

