function im=getanalyzeim(analyzeroot,volno,slc,info)
% Usage ... f=getanalyzeim(analyzeroot,vol#,slice,info)
%
% info= [xdim ydim zdim]

if (nargin==2),
  imgfile=sprintf('%s.img',analyzeroot);
  hdrfile=sprintf('%s.hdr',analyzeroot);
  slc=volno;
elseif (volno==0),
  imgfile=sprintf('%s.img',analyzeroot);
  hdrfile=sprintf('%s.hdr',analyzeroot);
else,
  imgfile=sprintf('%s_%04d.img',analyzeroot,volno);
  hdrfile=sprintf('%s_%04d.hdr',analyzeroot,volno);
end;

if nargin<4,
  hdr=getanalyzeinfo(hdrfile);
  info=[hdr(1) hdr(2) hdr(3)];
  if hdr(5)==4, info(4)=2; end;
  if hdr(5)==2, info(4)=1; end;
end;
if length(info)<4, info(4)=2; end;
if slc>info(3), error('Invalid slice'); end;

if info(4)==1,
  type='char';
else,
  type='short';
end;

fid=fopen(imgfile,'r');
if (fid<3), error(['Could not open file ',imgfile]); end;

stat=fseek(fid,info(4)*(slc-1)*info(1)*info(2),'bof');
if stat==-1,
  error(['Could not seek to slice ',int2str(slc)]);
end;

[im,cnt]=fread(fid,info(1:2),type);
if ( cnt~=(info(1)*info(2)) ),
  error(['Could not read slice ',int2str(slc),' (',int2str(cnt),')']);
end;

fclose(fid);

