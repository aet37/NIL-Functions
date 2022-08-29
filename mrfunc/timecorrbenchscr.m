
clear all

e1amp=100; c1=30;
e2amp=200; c2=100;
e3amp=1000;

locs=[25 25;42 25];

makeobj_flag=1;
prep_flag=1;
timecorr_flag=1;
calcsubs_flag=1;
clean_flag=1;

if (clean_flag),
  eval(sprintf('!rm /tmp/A.* /tmp/B.* /tmp/C.* /tmp/D.* /tmp/sl1.*'));
end;

optr=3.2;
nims=200;
tt=[1:nims]'*optr;
tt2=[1:nims/2]'*optr*2;

nevents=10;
eventperiod=20*optr;
ref1=zeros(nims,1); ref2=zeros(nims,1);
for m=1:nevents,
  ref1=ref1+gammafun(tt,2+(m-1)*eventperiod,.75,8.6,1); 
  ref2=ref2+gammafun(tt,2+(m-1)*eventperiod,.95,12.6,1);
end;
ref1=e1amp+c1*ref1+(0.050*e3amp*tt/optr/nims)+(0.000*e3amp*randn(size(ref1)));
ref2=e2amp+c2*ref2+(0.007*e3amp*tt/optr/nims)+(0.000*e3amp*randn(size(ref1)));
ref2a=e2amp+zeros(nims,1);
%ref1(1)=ref1(1)-e1amp;
%ref2(1)=ref2(1)-e2amp;

for m=1:nims,
  e1a(m)=round(ref1(m));
  e2a(m)=round(ref2(m));
  e2aa(m)=round(ref2a(m));
  e3a(m)=round(e3amp);
  e1=e1a(m)*ellipse(zeros([64 64]),25,25,5,8,0,1);
  e2=e2a(m)*ellipse(zeros([64 64]),42,25,5,8,0,1);
  e3=e3a(m)*ellipse(zeros([64 64]),34,32,18,24,0,1);
  obj=(e1+e2+e3);
  if (makeobj_flag),
    writeim(sprintf('/tmp/sl1.%03d',m),obj);
    %show(obj')
  end;
end; 

if (prep_flag),
  eval(sprintf('!renalt /tmp/sl1. "" %d 3 /tmp/A.sl1. /tmp/B.sl1.',nims));
end;

if (timecorr_flag),
  %wtype=[3 2];
  %wopts=[2 2 2];
  wtype=[1 2];
  wopts=[2 1];
  sl_timecorr([1:2:nims],'/tmp/A.',1,[64 64 2],[2:2:nims],wtype,wopts,1);
  sl_timecorr([2:2:nims],'/tmp/B.',1,[64 64 2],[1:2:nims],wtype,wopts,1);
end;

if (calcsubs_flag),
  for m=1:nims,
    im1=getslim('/tmp/A.',1,m,[64 64 2]);
    im2=getslim('/tmp/B.',1,m,[64 64 2]);
    im3=im1-im2;
    writeim(sprintf('/tmp/C.sl1.%03d',m),im3);
  end;
  for m=1:nims/2,
    im1=getslim('/tmp/',1,2*m-1,[64 64 2]);
    im2=getslim('/tmp/',1,2*m,[64 64 2]);
    im3=im1-im2;
    writeim(sprintf('/tmp/D.sl1.%03d',m),im3);
  end;
end;

tcA=getsltc('/tmp/A.',1,nims,locs,[64 64 2]);
tcB=getsltc('/tmp/B.',1,nims,locs,[64 64 2]);
tcC=getsltc('/tmp/C.',1,nims,locs,[64 64 2]);
tcD=getsltc('/tmp/D.',1,nims/2,locs,[64 64 2]);

bold=(e1a+e3a)';
perf=(e2a-e2amp)';

subplot(211)
plot(tt,bold,tt,tcA(:,1),tt,tcB(:,1),tt,tcA(:,1),'gx',tt,tcB(:,1),'rx')
subplot(212)
plot(tt,perf,tt,tcC(:,2),tt2,tcD(:,2))

berr=[bold-tcA(:,1) bold-tcB(:,1)]/bold(1);
perr=[perf-tcC(:,2)]/max(perf);
perr2=[perf(1:2:nims)-tcD(:,2)]/max(perf);

sum(berr.^2)/nims,
sum(perr.^2)/nims,

