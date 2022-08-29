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

if isstr(fname),
  stk=tiffread2c(fname);
else,
  stk=fname;
end;

if isempty(framerange),
  im1=1;
  imlast=length(stk);
else,
  im1=framerange(1);
  imlast=framerange(2);
end;


pim.filename=stk(im1).filename;
pim.width=stk(im1).width;
pim.height=stk(im1).height;
pim.nimages=[imlast-im1+1 length(stk)];
pim.framerange=[im1 imlast];
pim.projtype='mean';

if isfield(stk(im1),'data'),
  data_flag=1;
  tmpdata=double(stk(im1).data);
  if (medfilt_flag), tmpdata=medfilt2(tmpdata,mfiltk); end;
  tmpmeandata=mean(mean(tmpdata));
else,
  data_flag=0;
  tmpred=double(stk(im1).red);
  tmpgreen=double(stk(im1).green);
  tmpblue=double(stk(im1).blue);
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
end;

if data_flag,
  pim.data=tmpdata;
  pim.datax=mean(tmpdata,1);
  pim.datay=mean(tmpdata,2);
else,
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
end;

cnt=1;
for imno=im1+1:imlast,
  if (data_flag),
    tmpdata=double(stk(imno).data);
    if (medfilt_flag), tmpdata=medfilt2(tmpdata,mfiltk); end;
  else,
    tmpred=double(stk(imno).red);
    tmpgreen=double(stk(imno).green);
    tmpblue=double(stk(imno).blue);
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
  end;

  if (data_flag),
    pim.data=pim.data+tmpdata;
    pim.datax(cnt+1,:)=mean(tmpdata,1);
    pim.datay(:,cnt+1)=mean(tmpdata,2);
    pim.meandata(cnt+1)=tmpmeandata;
  else,
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
  end;

  cnt=cnt+1;
end;  

if data_flag,
  pim.data=pim.data/cnt;
  pim.dataavg=mean(reshape(pim.data,prod(size(pim.data)),1));
  pim.datastd=std(reshape(pim.data,prod(size(pim.data)),1));
else,
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
end;
pim.nimages=cnt;
pim.projrange=[im1 imno-1];

clear stk

if (nargout==0),
  if data_flag,
    figure(1)
    show(pim.data)
  else,
    figure(1)
    show(pim.red)
    orange256;
    figure(2)
    show(pim.green)
    green256;
  end;
end;

