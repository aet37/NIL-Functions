function [im,info]=readOIS3(fname,imno,prec,do_write)
% Usage ... [im,info]=readOIS3(fname,imno,prec,do_write)

% prec=[1:uint8,2:uint16,4:single,8:double];

do_tiffread=1;

if (nargin==0)|(isempty(fname)),
  [tmpname,tmppath]=uigetfile('*.*','Select a Lab Imaging File to Open');
  fname=[tmppath,tmpname];
  imno=1;
end;
  
if nargin<4, do_write=0; end;
if isempty(do_write), do_write=0; end;

do_transp=1;
do_tif=1;

if strcmp(fname(end-2:end),'raw'),
  if nargin==1, imno=1; end;
  [im,info]=readOIS(fname,imno);
  if do_transp,
    tmpim=zeros(size(im,2),size(im,1),size(im,3));
    for nn=1:size(im,3), tmpim(:,:,nn)=im(:,:,nn)'; end;
    clear im
    im=tmpim;
  end;
  return;
end;

if do_tif,
if strcmp(fname(end-2:end),'tif')|strcmp(fname(end-2:end),'TIF'),
  if nargin==1, imno=1; end;
  if iscell(imno),
    im1=imread(fname,imno{1}(1));
    im=single(zeros(size(im1,1),size(im1,2),imno{end}(end)));
    for nn=1:length(imno), 
      if length(imno{nn})==1, imno{nn}=[1:imno{nn}(1)]; end;
      if nn==1, 
        tmpfname=fname; clear fname ; fname{nn}=tmpfname;
      else,
        fname{nn}=sprintf('%s-file%03d.tif',tmpfname(1:end-4),nn);
      end;
    end;
    cnt=0;
    for nn=1:length(imno),
      disp(sprintf('  reading %s (%d)...',fname{nn},imno{nn}(end)));
      for mm=1:length(imno{nn}), cnt=cnt+1; im(:,:,cnt)=single(imread(fname{nn},imno{nn}(mm))); end;
    end;
  else,
    if length(imno)==1,
      im=single(imread(fname,imno(1)));
    else,
      im1=imread(fname,imno(1));
      if length(imno)==2, imno=[1:imno]; end;
      im=single(zeros(size(im1,1),size(im1,2),length(imno)));
      for mm=1:length(imno),
        for nn=1:length(imno), im(:,:,nn)=single(imread(fname,imno(nn))); end;
      end;
    end;
  end;
  return;
end;
end;     
  
if (nargout==2), 
    info=imfinfo(fname); 
    if isfield(info,'UnknownTags'),
        info.nImages=length(info.UnknownTags(2).Value);
    end
end;

if (nargin<3), prec=8; end;

if (nargin==1),
  if do_tiffread,
    stk=tiffread2(fname,1);
    im=double(stk.data);
  else,
    im=double(imread(fname));
  end;
else,
  %im=double(imread(fname,imno));
  if isstr(imno)|(length(imno)==2),
    if isstr(imno),
      if strcmp(imno,'all'),
        stk=tiffread2(fname);
      end;
      %if prec==4,
      %  im=single(zeros(size(stk(1).data,1),stk(1).data,2,length(stk)));
      %  for mm=1:size(im,3), im(:,:,mm)=single(stk(mm).data); end;
      %if prec==2,
      %  im=uint16(zeros(size(stk(1).data,1),stk(1).data,2,length(stk)));
      %  for mm=1:size(im,3), im(:,:,mm)=uint16(stk(mm).data); end;
      %else, %prec==8
      %  im=zeros(size(stk(1).data,1),stk(1).data,2,length(stk));
      %  for mm=1:size(im,3), im(:,:,mm)=double(stk(mm).data); end;
      %end;
    else,
      stk=tiffread2(fname,imno(1),imno(2));
    end;
    if isempty(stk), im=[]; return; end;    
    if prec==1,
      im=uint8(zeros(size(stk(1).data,1),size(stk(1).data,2),length(stk)));
      for mm=1:length(stk), im(:,:,mm)=uint8(stk(mm).data); end;
    elseif prec==2,
      im=uint16(zeros(size(stk(1).data,1),size(stk(1).data,2),length(stk)));
      for mm=1:length(stk), im(:,:,mm)=uint16(stk(mm).data); end;
    elseif prec==4,
      im=single(zeros(size(stk(1).data,1),size(stk(1).data,2),length(stk)));       
      for mm=1:length(stk), im(:,:,mm)=single(stk(mm).data); end;
    else,
      im=zeros(size(stk(1).data,1),size(stk(1).data,2),length(stk));
      for mm=1:length(stk), im(:,:,mm)=double(stk(mm).data); end;
    end;
  else,
    for mm=1:length(imno),
      stk=tiffread2(fname,imno(mm));
      if isempty(stk), im=[]; return; end;
      if prec==1,
        im(:,:,mm)=uint8(stk.data);
      elseif prec==2,
        im(:,:,mm)=uint16(stk.data);
      elseif prec==4,
        im(:,:,mm)=single(stk.data);
      else,
        im(:,:,mm)=double(stk.data);
      end;
    end;
  end;
end;

if do_write,
    tmpname=sprintf('%s.jpg',fname(1:end-4));
    disp(sprintf('  writing %s ...',tmpname));
    imwrite(imwlevel(im(:,:,1),[],1),tmpname,'JPEG','BitDepth',12,'Quality',100);
end;

if nargout==0,
    clear im
end;




