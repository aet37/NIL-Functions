function f=sl_corr(frootname,slc,reference,section,info,ext)
% Usage ... f=sl_corr(rootname,slice,reference,section,info)
%
% reference - reference waveform for correlation
% section- sections of the timecourse to regress only in images!
% sections can be the image #s to use, in that case reference should
% be of the same length as sections

% Image-course approach

if nargin<6,
  ext='';
end;

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

if length(section)>=3,
  disp('Doing sections (images)...');
  for m=1:length(section),
    im=getslim(frootname,slc,section(m),info,ext);
    sumim=sumim+im;
    sumref=sumref+reference(m);
    count=count+1;
  end;
  meanim=(1/count)*sumim;  %image
  meanref=(1/count)*sumref; %value
  count=1;
  for m=1:length(section),
    im=getslim(frootname,slc,section(m),info,ext);
    sumnx2=sumnx2+(reference(m)-meanref).*(reference(m)-meanref);
    sumny2=sumny2+(im-meanim).*(im-meanim);
    sumnxy=sumnxy+(reference(m)-meanref)*(im-meanim);
    count=count+1;
  end;
elseif length(section)==2,
  disp(['Doing sections...']);
  nsections=length(section)/2;
  for k=1:nsections,
    for m=section(2*k-1):section(2*k),
      im=getslim(frootname,slc,m,info,ext);
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
      im=getslim(frootname,slc,m,info,ext);
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
    im=getslim(frootname,slc,k,info,ext);
    sumim=sumim+im;
    count=count+1;
  end;
  meanim=(1/count)*sumim;  %image
  meanref=mean(reference); %value
  for k=section(1):section(2),
    im=getslim(frootname,slc,k,info,ext);
    sumnx2=sumnx2+(reference(k)-meanref).*(reference(k)-meanref);
    sumny2=sumny2+(im-meanim).*(im-meanim);
    sumnxy=sumnxy+(reference(k)-meanref)*(im-meanim);
  end;
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

