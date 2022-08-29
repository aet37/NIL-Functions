function f=dm_corr(dmfile,slc,reference,section)
% Usage ... f=dm_corr(dmfile,slice,reference,section)
%
% dmfile- dmod filename
% reference - reference waveform for correlation
% section- sections of the timecourse to regress only in images!

% Image-course approach

dminfo=getdmodinfo(dmfile);
dmfid=fopen(dmfile,'r');
if dmfid<3,
  error('Could not open file!');
end;
sumim=0;
sumref=0;
count=0;
sumnx=0; sumny=0; sumnxy=0; sumnx2=0; sumny2=0;

%t=clock;
%disp(['Time:']);
%disp(t);
disp(['Initiating Analysis...']);

if exist('section'),
  disp(['Doing sections...']);
  nsections=length(section)/2;
  for k=1:nsections,
    for m=section(2*k-1):section(2*k),
      im=getdmodim(dmfid,m,slc);
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
      im=getdmodim(dmfid,m,slc);
      sumnx2=sumnx2+(reference(m)-meanref).*(reference(m)-meanref);
      sumny2=sumny2+(im-meanim).*(im-meanim);
      sumnxy=sumnxy+(reference(m)-meanref)*(im-meanim);
      count=count+1;
    end;
  end;
  disp(['Sections Done...']);
else,
  for k=1:dminfo(8),
    im=getdmodim(dmfid,k,slc);
    sumim=sumim+im;
    count=count+1;
  end;
  meanim=(1/count)*sumim;  %image
  meanref=mean(reference); %value
  for k=1:dminfo(8),
    im=getdmodim(dmfid,k,slc);
    sumnx2=sumnx2+(reference(k)-meanref).*(reference(k)-meanref);
    sumny2=sumny2+(im-meanim).*(im-meanim);
    sumnxy=sumnxy+(reference(k)-meanref)*(im-meanim);
  end;
end;

den=((sumnx2^(0.5))*(sumny2.^(0.5)));

for m=1:dminfo(2), for n=1:dminfo(3),
  if (den(m,n)==0)|(den(m,n)<1e-6),
    f(m,n)=0;
  else,
    f(m,n)=sumnxy(m,n)/den(m,n);
  end;  
end; end;

%disp(['Time: ']);
%disp(clock-t);
disp(['Done...']);

fclose(dmfid);
