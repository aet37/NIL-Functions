function writeSingIm(fname)
% Usage ... writeSingIm(fname_or_froot)

if strcmp(fname(end),'/')|strcmp(fname(end),'\')
  tmpname=dir([fname,'*.tif']);
  wname=sprintf('Sing%s.jpg',fname(end-4:end-1));
else,
  tmpname=dir(fname);
  tmpwname=dir('Sing*.jpg');
  wname=sprintf('Sing%04d.jpg',length(tmpwname)+1);
end;

if ~isempty(tmpname),
  for mm=1:length(tmpname),
    im(:,:,mm)=single(imread([tmpname(mm).folder,filesep,tmpname(mm).name]));
  end
  imwrite(imwlevel(im,[],1),wname,'JPEG','Quality',100);
end

