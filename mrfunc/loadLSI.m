function y=loadLSI(fname,imno)
% Usage ... y=loadLSI(fname,imno)


if strcmp(fname(end-4:end),'.rawf'),
  file_type=1;
elseif strcmp(fname(end-3:end),'.stk'),
  file_type=2;
elseif strcmp(fname(end-3:end),'.mat'),
  file_type=3;
else,
  file_type=2;
end;

if file_type==1,
  fid=fopen(fname,'r');
  if fid<3, error(sprintf('Could not open file %s for reading',fname)); end;
  verinfo=char(fread(fid,4,'char'));	% version
  dateinfo=char(fread(fid,24,'char'));	 % date
  nx=fread(fid,1,'short'); %width
  ny=fread(fid,1,'short'); %height
  nf=fread(fid,1,'short'); %frames
  nc=fread(fid,1,'short'); %not used
  hdroff=36;
end;

for mm=1:length(imno),
  if file_type==2,
    tmpstk=tiffread2(fname,imno(mm));
    y(:,:,mm)=double(tmpstk.data);
  elseif file_type==3,
    eval(sprintf('load %s kim_%04d',mm));
    eval(sprintf('tmpim=kim_%04d; clear kim_%04d',mm,mm));
    y(:,:,mm)=tmpim;
  else,
    fpos=hdroff+(imno(mm)-1)*nx*ny*4;
    fseek(fid,fpos,'bof');
    tmpim=fread(fid,[nx ny],'single');
    y(:,:,mm)=tmpim;
  end;
end;

if file_type==1,
  fclose(fid);
end;
