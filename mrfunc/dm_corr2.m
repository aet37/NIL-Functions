function f=dm_corr2(dmfile1,slc,reference,section,dmfile2,dmfile3,dmfile4,dmfile5,dmfile6,dmfile7,dmfile8,dmfile9)
% Usage ... f=dm_corr2(dmfile,slice,reference,section,dmfile2,dmfile3,...)
%
% Same as dm_corr but able to use multiple files to calcualte correlation
%
% dmfile- dmod filename
% reference - reference waveform for correlation
% section- sections of the timecourse to regress only in images!

% Image-course approach

dminfo=getdmodinfo(dmfile1);
sumim=0;
sumref=0;
count=0;
sumnx=0; sumny=0; sumnxy=0; sumnx2=0; sumny2=0;

%t=clock;
%disp(['Time:']);
%disp(t);

if nargin<4,
  nfiles=1;
  dosect=0;
else,
  if isstr(section),
    dosect=0;
    nfiles=nargin-2;
    if nargin==4,
      dmfile2=section;
    else,
      for nn=nfiles:-1:2,
        eval(['dmfile',int2str(nn),'=dmfile',int2str(nn-1),';']);
      end;
      dmfile2=section;
    end;
  else,
    dosect=1;
    nfiles=nargin-3;
  end;
end;

disp(['Initiating Analysis on ',int2str(nfiles),' files...']);

if dosect,

  disp(['Doing sections...']);
  for nn=1:nfiles,
    eval(['dmfid=fopen(dmfile',int2str(nn),',''r'');']);
    if dmfid<3, error(['Could not open file ',int2str(nn),'!']); end;
    nsections=length(section)/2;
    for k=1:nsections,
      for m=section(2*k-1):section(2*k),
        im=getdmodim(dmfid,m,slc);
        sumim=sumim+im;
        sumref=sumref+reference(m);
        count=count+1;
      end;
    end;
    fclose(dmfid);
  end;
  meanim=(1/count)*sumim;  %image
  meanref=(1/count)*sumref; %value
  for nn=1:nfiles,
    eval(['dmfid=fopen(dmfile',int2str(nn),',''r'');']);
    if dmfid<3, error(['Could not open file ',int2str(nn),'!']); end;
    for k=1:nsections,
      disp(['Section ',int2str(k)]);
      for m=section(2*k-1):section(2*k),
        im=getdmodim(dmfid,m,slc);
        sumnx2=sumnx2+(reference(m)-meanref).*(reference(m)-meanref);
        sumny2=sumny2+(im-meanim).*(im-meanim);
        sumnxy=sumnxy+(reference(m)-meanref)*(im-meanim);
      end;
    end; 
    fclose(dmfid);
  end;
  disp(['Sections Done...']);

else,

  for nn=1:nfiles,
    eval(['dmfid=fopen(dmfile',int2str(nn),',''r'');']);
    if dmfid<3, error(['Could not open file ',int2str(nn),'!']); end;
    for k=1:dminfo(8),
      im=getdmodim(dmfid,k,slc);
      sumim=sumim+im;
      count=count+1;
    end;
    fclose(dmfid);
  end;
  meanim=(1/count)*sumim;  %image
  meanref=mean(reference); %value
  for nn=1:nfiles,
    eval(['dmfid=fopen(dmfile',int2str(nn),',''r'');']);
    if dmfid<3, error(['Could not open file ',int2str(nn),'!']); end;
    for k=1:dminfo(8),
      im=getdmodim(dmfid,k,slc);
      sumnx2=sumnx2+(reference(k)-meanref).*(reference(k)-meanref);
      sumny2=sumny2+(im-meanim).*(im-meanim);
      sumnxy=sumnxy+(reference(k)-meanref)*(im-meanim);
    end;
    fclose(dmfid);
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

