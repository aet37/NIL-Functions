function [f,cnt,g,h]=read_zeros(filename,pulse,g1,g2,g3,g4,g5,g6)
% Usage ... [f,cnt,g]=read_zeros(filename,pulse,g1,g2,g3,g4,g5,g6)
%
% pulse - 'sf9','sf9raw','sf3d','ros'
%   g1 - number reps (nph1)
%   g2 - number reps mult (npmult)
%   g3 - spirals
%   g4 - slices
%   g5 - frame size
%   g6 - # phase encodes

FILEOFF=30;

npts_total=g1*g2*g3*g4;
npts=g1*g2*g3;

fid=fopen(filename,'r');
if (fid<3),
  error('Could not open file!');
end;
fseek(fid,0,'bof');

f=[0 0];
if strcmp(pulse,'sf9'),
  cnt=1; offset=0;
  for n=1:npts_total,
    fseek(fid,offset,'bof');
    [tmpbuff,nitems]=fread(fid,2,'short'); tmpbuff=tmpbuff(:);
    if (nitems~=2),
      error('Did not read 2 items');
    end;
    f(cnt,:)=tmpbuff';
    cnt=cnt+1; offset=offset+8;
  end;
elseif strcmp(pulse,'sf3d'),
  cnt=1; offset=0;
  npts_total=npts_total*g6;
  for n=1:npts_total,
    fseek(fid,offset,'bof');
    tmpbuff=fread(fid,2,'short'); tmpbuff=tmpbuff(:);
    f(cnt,:)=tmpbuff';
    cnt=cnt+1; offset=offset+8;
  end;
elseif strcmp(pulse,'sf9raw'),
  k=0; cnt=1;
  for m=1:g4,
    for n=1:npts,
      if ~rem(n-1,g1) k=k+1; end;
      [tmp,r,i]=fidread(fid,'sf9',m,n+k);
      f(cnt,:)=[r(1) i(1)];
      cnt=cnt+1;
      clear tmp r i
    end;    
  end;
elseif strcmp(pulse,'ros'),
  disp('Reading zeros from rosette sequence...');
  cnt=1; offset=0;
  for n=1:npts_total,
    fseek(fid,offset,'bof');
    [tmpbuff,nitems]=fread(fid,2,'short'); tmpbuff=tmpbuff(:);
    if (nitems~=2), error('Did not read 2 items'); end;
    f(cnt,:)=tmpbuff';
    cnt=cnt+1; offset=offset+8;
  end;
end;

cnt=cnt-1;

fclose(fid);


