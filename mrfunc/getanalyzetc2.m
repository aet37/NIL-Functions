function f=getanalyzetc2(analyzeroot,nvols,slc,pix,ord,info)
% Usage ... f=getanalyzetc2(analyzeroot,nvols,slice,pix,ord,info)
%
% info= [xdim ydim zdim]

imgfile=sprintf('%s%04d.img',analyzeroot,1);
hdrfile=sprintf('%s%04d.hdr',analyzeroot,1);

if nargin<6,
  hdr=getanalyzeinfo(hdrfile);
  info=[hdr(1) hdr(2) hdr(3)];
  if hdr(5)==4, info(4)=2; end;
  if hdr(5)==2, info(4)=1; end;
end;
if nargin<5, ord=0; end;
if length(info)<4, info(4)=2; end;
%info,
if slc>info(3), error('Invalid slice'); end;

if info(4)==1,
  type='char';
else
  type='short';
end;
if length(info)<5, info(5)=1; end;
if info(5)==2, mtype='b'; else, mtype='l'; end;

for m=1:nvols,

  imgfile=sprintf('%s%04d.img',analyzeroot,m);
  hdrfile=sprintf('%s%04d.hdr',analyzeroot,m);

  fid=fopen(imgfile,'r',mtype);
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

  for n=1:size(pix,1),
    f(m,n)=im(pix(n,1),pix(n,2));
  end;

end;

if (ord~=0),
  disp(sprintf('Detrending TCs with %d th oder polynomial',ord));
  fd=tcdetrend(f,ord);  
  f=fd;
end;

