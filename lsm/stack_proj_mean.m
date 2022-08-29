function pim=stack_proj_mean(fname,framerange,medfilt_flag)
% Usage ... pim=stack_proj_mean(fname,framerange,medfilt_flag)

% add range of proj images, mean values for each channel per image,
% intensity correction? 

if nargin<3, medfilt_flag=0; end;
if nargin<2, framerange=[], end;

if length(medfilt_flag)==1,
  mfiltk=[3 3];
else,
  mfiltk=medfilt_flag;
  medfilt_flag=1; 
end;
if isempty(framerange), im1=1; else, im1=framerange(1); end;

tmpim=tiffread2c(fname,im1);
disp(sprintf('  read im# %d',im1));

pim.filename=tmpim.filename;
pim.width=tmpim.width;
pim.height=tmpim.height;
pim.nimages=1;
pim.projtype='mean';

tmpred=double(tmpim.red);
tmpgreen=double(tmpim.green);
tmpblue=double(tmpim.blue);
if ~isempty(tmpred),
  if (medfilt_flag), tmpred=medfilt2(tmpred,mfiltk); end;
  tmpmeanred=mean(mean(tmpred));
else, tmpmeanred=[];
end;
if ~isempty(tmpgreen),
  if (medfilt_flag), tmpgreen=medfilt2(tmpgreen,mfiltk); end;
  tmpmeangreen=mean(mean(tmpgreen));
else, tmpmeangreen=[];
end;
if ~isempty(tmpblue),
  if (medfilt_flag), tmpblue=medfilt2(tmpblue,mfiltk); end;
  tmpmeanblue=mean(mean(tmpblue));
else, tmpmeanblue=[];
end;

pim.red=tmpred;
pim.redx=mean(tmpred,1);
pim.redy=mean(tmpred,2);
pim.green=tmpgreen;
pim.greenx=mean(tmpgreen,1);
pim.greeny=mean(tmpgreen,2);
pim.blue=tmpblue;
pim.bluex=mean(tmpblue,1);
pim.bluey=mean(tmpblue,2);
pim.meanred=tmpmeanred;
pim.meangreen=tmpmeangreen;
pim.meanblue=tmpmeanblue;
pim.medfiltk=medfilt_flag;
if (medfilt_flag), pim.medfiltk=mfiltk; end;

cnt=1; imno=im1+1;
if isempty(framerange), imlast=1024; else, imlast=framerange(2); end;
ok_flag=0;
while(~ok_flag),
  tmpim=tiffread2c(fname,imno+1);
  if isempty(tmpim)|(imno>imlast),
    ok_flag=1;
    disp(sprintf('  last image'));
    break;
  end;

  disp(sprintf('  read im# %d',imno));
  tmpred=double(tmpim.red);
  tmpgreen=double(tmpim.green);
  tmpblue=double(tmpim.blue);
  if ~isempty(tmpred),
    if (medfilt_flag), tmpred=medfilt2(tmpred,mfiltk); end;
    tmpmeanred=mean(mean(tmpred));
  end;
  if ~isempty(tmpgreen),
    if (medfilt_flag), tmpgreen=medfilt2(tmpgreen,mfiltk); end;
    tmpmeangreen=mean(mean(tmpgreen));
  end;
  if ~isempty(tmpblue),
    if (medfilt_flag), tmpblue=medfilt2(tmpblue,mfiltk); end;
    tmpmeanblue=mean(mean(tmpblue));
  end;

  if ~isempty(pim.red),
    pim.red=pim.red+tmpred;
    pim.redx(cnt+1,:)=mean(tmpred,1);
    pim.redy(:,cnt+1)=mean(tmpred,2);
    pim.meanred(cnt+1)=tmpmeanred;
  end;
  if ~isempty(pim.green),
    pim.green=pim.green+tmpgreen;
    pim.greenx(cnt+1,:)=mean(tmpgreen,1);
    pim.greeny(:,cnt+1)=mean(tmpgreen,2);
    pim.meangreen(cnt+1)=tmpmeangreen;
  end;
  if ~isempty(pim.blue),
    pim.blue=pim.blue+tmpblue;
    pim.bluex(cnt+1,:)=mean(tmpblue,1);
    pim.bluey(:,cnt+1)=mean(tmpblue,2);
    pim.meanblue(cnt+1)=tmpmeanblue;
  end;

  cnt=cnt+1; imno=imno+1;
end;  

if ~isempty(pim.red),
  pim.red=pim.red/cnt;
  pim.redavg=mean(reshape(pim.red,prod(size(pim.red)),1));
  pim.redstd=std(reshape(pim.red,prod(size(pim.red)),1));
end;
if ~isempty(pim.green),
  pim.green=pim.green/cnt; 
  pim.greenavg=mean(reshape(pim.green,prod(size(pim.green)),1));
  pim.greenstd=std(reshape(pim.green,prod(size(pim.green)),1));
end;
if ~isempty(pim.blue),
  pim.blue=pim.blue/cnt;
  pim.blueavg=mean(reshape(pim.blue,prod(size(pim.blue)),1));
  pim.bluestd=std(reshape(pim.blue,prod(size(pim.blue)),1));
end;
pim.nimages=cnt;
pim.projrange=[im1 imno-1];

if (nargout==0),
  figure(1)
  show(pim.red)
  orange256;
  figure(2)
  show(pim.green)
  green256;
end;

