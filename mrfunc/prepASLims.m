function prepASLims(fpath,fsubpath,pfile,acqinfo,prepinfo) 
% Usage ... prepASLims(fpath,fsubpath,pfile,acqinfo,prepinfo) 
%
% acqinfo = [nreps nsl dim TR slacqtime]
% prepinfo = [recon prep timecorr sub subi phs map]

if (nargin<4), error('Need at least 4 arguments!'); end;

if (nargin<5),
  recon_flag=1; 
  prepare_flag=1; 
  timecorr_flag=1; 
  calcsubs_flag=1; 
  calcsubsi_flag=1; 
  phase_flag=0;
  map_flag=0;
else,
  recon_flag=prepinfo(1);
  prepare_flag=prepinfo(2);
  timecorr_flag=prepinfo(3);
  calcsubs_flag=prepinfo(4);
  calcsubsi_flag=prepinfo(5);
  phase_flag=prepinfo(6);
  map_flag=prepinfo(7);
end;

nreps=acqinfo(1);
nsl=acqinfo(2);
slinf=[acqinfo(3) acqinfo(3) 2];
optr=acqinfo(4);
if length(acqinfo)>4,
  slacqtime=acqinfo(5);
else,
  slacqtime=33.7e-3;
end;

disp(sprintf('ACQ INFO:\n #reps= %d, #sl= %d, dim= %d, TR= %f, slacqtime= %f',nreps,nsl,slinf(1),optr,slacqtime));
disp(sprintf('PREP INFO:\n recon= %d, prep= %d, timecorr= %d, subs= %d, subsi= %d, phase= %d',recon_flag,prepare_flag,timecorr_flag,calcsubs_flag,calcsubsi_flag,phase_flag));


eval(sprintf('cd %s',fpath));

% recon images
if (recon_flag),
  if (phase_flag), phsstr='-p'; else, phsstr=''; end;
  disp(sprintf('reconstructing %s%s ...',fpath,pfile));
  if (map_flag),
    eval(sprintf('!gsp18 -m %s',pfile));
    eval(sprintf('!gsp18 -h -l %s %s',phsstr,pfile));
  else,
    eval(sprintf('!gsp18 -l %s %s',phsstr,pfile));
  end;
  eval(sprintf('!mkdir %s',fsubpath));
  eval(sprintf('!mv sl* %s.',fsubpath));
end;

eval(sprintf('cd %s%s',fpath,fsubpath));

% prepare images
if (prepare_flag),
  disp(sprintf('preparing data ...'));
  for slno=1:nsl,
    eval(sprintf('!renalt %s%ssl%d. "" %d 3 %s%sA.sl%d. %s%sB.sl%d.',fpath,fsubpath,slno,nreps,fpath,fsubpath,slno,fpath,fsubpath,slno));
    if (phase_flag),
      eval(sprintf('!renalt %s%ssl%d.phs. "" %d 3 %s%sA.sl%d.phs. %s%sB.sl%d.phs.',fpath,fsubpath,slno,nreps,fpath,fsubpath,slno,fpath,fsubpath,slno));
    end;
  end;
end;

% sinc-interpolate to missing locations
if (timecorr_flag),
  disp(sprintf('time correcting slices ...'));
  wtype=[1 2];
  wopts=[2 2 2];
  for slno=1:nsl,
    %sl_timecorr([1:2:nreps],[fpath,fsubpath,'A.'],slno,slinf,[2:2:nreps]+(slno-1)*slacqtime,wtype,wopts,1);
    %sl_timecorr([2:2:nreps],[fpath,fsubpath,'B.'],slno,slinf,[1:2:nreps]+(slno-1)*slacqtime,wtype,wopts,1);
    sl_timecorr([1:2:nreps],[fpath,fsubpath,'A.'],slno,slinf,[2:2:nreps],wtype,wopts,1);
    sl_timecorr([2:2:nreps],[fpath,fsubpath,'B.'],slno,slinf,[1:2:nreps],wtype,wopts,1);
    if (phase_flag),
      sl_timecorr([1:2:nreps],[fpath,fsubpath,'A.'],slno,slinf,[2:2:nreps],wtype,wopts,1,'phs');
      sl_timecorr([2:2:nreps],[fpath,fsubpath,'B.'],slno,slinf,[1:2:nreps],wtype,wopts,1,'phs');
    end;
  end;
end;

% calculate subtraction
if (calcsubsi_flag),
  disp(sprintf('calculating common time subtractions ...'));
  for slno=1:nsl,
  for m=1:nreps,
    im1=getslim([fpath,fsubpath,'A.'],slno,m,slinf);
    im2=getslim([fpath,fsubpath,'B.'],slno,m,slinf);
    if (phase_flag),
      im1=im1.*exp(j*getslim([fpath,fsubpath,'A.'],slno,m,slinf,'phs')/1000);
      im2=im2.*exp(j*getslim([fpath,fsubpath,'B.'],slno,m,slinf,'phs')/1000);
      im3=round(abs(im1-im2));
    else,
      im3=im1-im2;
    end;
    fname=sprintf('%s%sC.sl%d.%03d',fpath,fsubpath,slno,m);
    writeim(fname,im3);
  end;
  end;
end;

% calculate subtraction from adjacent pairs
if (calcsubs_flag),
  disp(sprintf('calculating adjacent pair subtractions ...'));
  for slno=1:nsl,
  for m=1:nreps/2,
    im1=getslim([fpath,fsubpath],slno,2*m-1,slinf);
    im2=getslim([fpath,fsubpath],slno,2*m,slinf);
    if (phase_flag),
      im1=im1.*exp(j*getslim([fpath,fsubpath],slno,2*m-1,slinf,'phs')/1000);
      im2=im2.*exp(j*getslim([fpath,fsubpath],slno,2*m,slinf,'phs')/1000);
      im3=round(abs(im1-im2));
    else,
      im3=im1-im2;
    end;  
    fname=sprintf('%s%sD.sl%d.%03d',fpath,fsubpath,slno,m);
    writeim(fname,im3);
  end;
  end;
end;

eval(sprintf('cd %s',fpath));

