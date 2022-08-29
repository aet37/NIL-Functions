function f=sl_volcorr(frootname,reference,section,info)
% Usage ... f=sl_volcorr(rootname,reference,section,info)
%
% reference - reference waveform for correlation
% section- sections of the timecourse to regress only in images!
% info- [x y z]dims

% Image-course approach

if nargin<3,
  info=[64 64 1];
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
  disp(['Doing sections...']);
  for nn=1:info(3),
  disp(sprintf('  slice #%d/%d',nn,info(3)));
  nsections=length(section)/2;
  for k=1:nsections,
    for m=section(2*k-1):section(2*k),
      im=getslim(frootname,nn,m,info(1:2));
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
      im=getslim(frootname,nn,m,info(1:2));
      sumnx2=sumnx2+(reference(m)-meanref).*(reference(m)-meanref);
      sumny2=sumny2+(im-meanim).*(im-meanim);
      sumnxy=sumnxy+(reference(m)-meanref)*(im-meanim);
      count=count+1;
    end;
  end;
  sumnxyvol(:,:,nn)=sumnxy;
  denvol(:,:,nn)=((sumnx2^(0.5))*(sumny2.^(0.5)));
  end;
  disp(['Sections Done...']);
else,
  if length(section)==1, section(2)=section(1); section(1)=1; end;
  for nn=1:info(3),
  disp(sprintf('  slice #%d/%d',nn,info(3)));
  for k=section(1):section(2),
    im=getslim(frootname,nn,k,info(1:2));
    sumim=sumim+im;
    count=count+1;
  end;
  meanim=(1/count)*sumim;  %image
  meanref=mean(reference); %value
  for k=section(1):section(2),
    im=getslim(frootname,nn,k,info(1:2));
    sumnx2=sumnx2+(reference(k)-meanref).*(reference(k)-meanref);
    sumny2=sumny2+(im-meanim).*(im-meanim);
    sumnxy=sumnxy+(reference(k)-meanref)*(im-meanim);
  end;
  sumnxyvol(:,:,nn)=sumnxy;
  denvol(:,:,nn)=((sumnx2^(0.5))*(sumny2.^(0.5)));
  end;
end;

for nn=1:info(3),
for m=1:info(1), for n=1:info(2),
  if (denvol(m,n,nn)==0)|(denvol(m,n,nn)<1e-6),
    f(m,n,nn)=0;
  else,
    f(m,n,nn)=sumnxyvol(m,n,nn)/denvol(m,n,nn);
  end;  
end; end;
end;

%disp(['Time: ']);
%disp(clock-t);
disp(['Done...']);

