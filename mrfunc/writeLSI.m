function writeLSI(fname,neig,nbin,tau_flag,write_type)
% Usage ... writeLSI(fname,neig,nbin,tau_flag,write_type)
%
% Typically, neig=[5 5], nbin=1, tau_flag=0,
%   write_type=[1:rawf,2:TIFstk,3:mat]

% dependencies: readOIS, imbin, tiffread2

if nargin<5, write_type=1; end;
if nargin<4, tau_flag=0; end;
if nargin<3, nbin=1; end;

if write_type==2,
  outname=sprintf('%s_LSIk.stk',fname(1:end-4));
elseif write_type==3,
  outname=sprintf('%s_LSIk.mat',fname(1:end-4));
else,
  outname=sprintf('%s_LSIk.rawf',fname(1:end-4));
end;

% check incoming file type
if (strcmp(fname(end-2:end),'stk')|strcmp(fname(end-2:end),'tif')),
  stk_flag=1;
else,
  stk_flag=0;
end;

% read header if not a stack/tif file and write it
if ~stk_flag,
  fid=fopen(fname,'r');
  if fid<3, error(sprintf('Could not open file %s for reading',fname)); end;
  verinfo=char(fread(fid,4,'char'));	% version
  dateinfo=char(fread(fid,24,'char'));	 % date
  nx=fread(fid,1,'short'); %width
  ny=fread(fid,1,'short'); %height
  nf=fread(fid,1,'short'); %frames
  nc=fread(fid,1,'short'); %not used
  fclose(fid);
  hdroff=36;
end;

if write_type==1,
  ofid=fopen(outname,'w');
  if ofid<3, error(sprintf('Could not open file %s for writing',outname)); end;
end;


%
% Main Function
%

if stk_flag,
    
  % stk/tif in-file format
  cnt=0;
  found=0;
  while(~found),
    % read image
    cnt=cnt+1; tmpstk=tiffread2(fname,cnt);
    if isempty(tmpstk), cnt=cnt-1; found=1; break; end;
    % turn it to speckle contrast
    [tmpstd,tmpavg,tmpcon]=imstd_mex(double(tmpstk.data),neig,1,1);
    % make it even size
    ii1=floor(size(tmpcon,1)/2)*2;
    ii2=floor(size(tmpcon,2)/2)*2;
    tmpcon2=tmpcon(1:ii1,1:ii2);
    if nbin>1, tmpcon22=imbin(tmpcon2,nbin); clear tmpcon2 ; tmpcon2=tmpcon22; end;
    if (cnt==1), outcnt=prod(size(tmpcon2)); end;
    % write it
    if write_type==2,
      imwrite(tmpcon2,outname,'TIFF','Compression','none','WriteMode','append');
    elseif write_type==3,
      eval(sprintf('kim_%04d=tmpcon2;',cnt));
      if cnt==1,
        eval(sprintf('save %s kim_%04d',cnt));
      else,
        eval(sprintf('save %s -append kim_%04d',cnt));
      end;
      eval(sprintf('clear kim_%04d',cnt));
    else,
      if cnt==1,
        tmp1=tmpstk.datetime;  ddtt='                            ';
        if length(tmp1)>24, ddtt(1:24)=tmp1(1:24); else, ddtt(1:length(tmp1))=tmp1; end;
        fwrite(ofid,'v1.1','char');
        fwrite(ofid,ddtt(1:24),'char');
        fwrite(ofid,floor(size(tmpcon2,1)),'short');
        fwrite(ofid,floor(size(tmpcon2,2)),'short');
        fwrite(ofid,10000,'short'); 
        fwrite(ofid,1,'short');
      end;    
      tmpcnt=fwrite(ofid,single(tmpcon2),'float32');
      if tmpcnt~=outcnt, error(sprintf('  could not write data to %s (%d)',outname,cnt)); end;
    end;
    disp(sprintf('  writing image# %d',cnt));
  end;    
  if write_type==1,
    fseek(ofid,32,'bof');
    fwrite(ofid,cnt,'short');
  end;
  
else,
  
  for mm=1:nf,
    % read image
    tmpim=readOIS(fname,mm);
    [tmpstk,tmpavg,tmpcon]=imstd_mex(tmpim,neig,1,1);
    % make it even size
    ii1=floor(size(tmpcon,1)/2)*2;
    ii2=floor(size(tmpcon,2)/2)*2;
    tmpcon2=tmpcon(1:ii1,1:ii2);
    if nbin>1, tmpcon22=imbin(tmpcon2,nbin); clear tmpcon2 ; tmpcon2=tmpcon22; end;
    if mm==1, outcnt=prod(size(tmpcon2)); end;
    % write it
    if write_type==2,
      imwrite(tmpcon2,outname,'TIFF','Compression','none','WriteMode','append');
    elseif write_type==3,
      eval(sprintf('kim_%04d=tmpcon2;',cnt));
      if cnt==1,
        eval(sprintf('save %s kim_%04d',cnt));
      else,
        eval(sprintf('save %s -append kim_%04d',cnt));
      end;
      eval(sprintf('clear kim_%04d',cnt));
    else,
      if mm==1,
        fwrite(ofid,verinfo,'char');
        fwrite(ofid,dateinfo,'char');
        fwrite(ofid,floor(size(tmpcon2,1)),'short');
        fwrite(ofid,floor(size(tmpcon2,2)),'short');
        fwrite(ofid,nf,'short'); 
        fwrite(ofid,nc,'short');
      end;    
      tmpcnt=fwrite(ofid,single(tmpcon2),'float32');
      if tmpcnt~=outcnt, error(sprintf('  could not write data to %s (%d)',outname,cnt)); end;
    end;
    disp(sprintf('  writing image# %d',mm));
  end;    

end;

if write_type==1,
  fclose(ofid);
end;
