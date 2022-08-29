function [tc,uwflag,dim_locs]=getOIStc(fname,locs,im,check_tcs)
% Usage ... y=getOIStc(fname,locs,imno)
%

if (nargin<4), check_tcs=0; end;

[dim,head]=readOIS(fname);

for nn=1:size(locs,1),
  dim_locs(nn)=dim(locs(nn,1),locs(nn,2));
end;

verbose_flag=1;

fid=fopen(fname,'rb','l');
if (fid<3), error('Could not open file!'); end;
headoffset=head.offset+2*head.nx*head.ny;
fseek(fid,headoffset,'bof');
fpos=ftell(fid);

if nargin<3,
  im=head.nfr;
end;
if length(im)==1,
  im=[1:im];
end;

for mm=1:length(im),
  fseek(fid,fpos+head.nx*head.ny*(im(mm)-1)*1,'bof');
  tmpim=int8(fread(fid,[head.nx head.ny],'int8'));
  for nn=1:size(locs,1),
    tc(mm,nn)=int8(tmpim(locs(nn,1),locs(nn,2)));
  end;
end;

fclose(fid);

if (check_tcs),
  for mm=1:size(locs,1),
    tmp=double(tc(:,mm));
    ii=find(tmp>=127);
    if isempty(ii),
      uwflag(mm)=0;
    else,
      uwflag=1;
    end;
  end;
  if sum(uwflag)>0,
    for mm=1:size(locs,1),
      tc_big(:,mm)=double(tc(:,mm));
      if (uwflag(mm)), tc_big(:,mm)=unwrap(tc_big(:,mm),127.5); end;
    end;
    clear tc
    tc=tc_big;
    clear tc_big
  end;
else,
  uwflag=[];
end;


