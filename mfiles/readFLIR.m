function y=readFLIR(fname)
% Usage ... y=readFLIR(fname)

if strcmp(fname(end),'/'),
  do_folder=1;
  tmpdir=dir([fname]);
  if strcmp(tmpdir(1).name,'.'), tmpdir=tmpdir(3:end); end;
  tmpname=tmpdir(1);
  disp(sprintf('  #files= %d',length(tmpdir)));
  disp(sprintf('  fname1= %s',tmpdir(1).name));
else,
  do_folder=0;
  tmpname=dir(fname);
end;

if strcmp(tmpname.name(end-2:end),'raw')|strcmp(tmpname.name(end-2:end),'RAW'),
  do_imread=0;
else,
  do_imread=1;
end;

if do_imread,
  y=imread(tmpname.name);
else,
  if do_folder,
    tmpfid=fopen([fname,tmpname.name]);
  else,
    tmpfid=fopen(fname);
  end;
  y=fread(tmpfid,[1920 1200],'uint16')';
  fclose(tmpfid);
end;

if do_folder,
  y_orig=y;
  if do_imread,
    for mm=2:length(tmpdir),
      y(:,:,mm)=imread([fname,tmpdir(mm).name]);
    end;
  else,
    y=uint16(zeros(size(y_orig,1),size(y_orig,2),length(tmpdir)));
    y(:,:,1)=y_orig;
    for mm=2:length(tmpdir),
      %[fname,tmpdir(mm).name]
      tmpfid=fopen([fname,tmpdir(mm).name]);
      y(:,:,mm)=fread(tmpfid,[1920 1200],'uint16')';
      fclose(tmpfid);
    end;
  end;
end;


if nargout==0,
  show(double(y(:,:,1)))
  clear y
end;

  