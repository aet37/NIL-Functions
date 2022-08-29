function f=air2dmod(x,y,z,t,hdrdmfile,outfile)
% Usage ... f=air2dmod(x,y,z,t,hdrdmfile,outfile)
%

if nargin~=3,
  disp('Reading AIR files...');
  tmp=air_readin2(x,y,t,z);
else,
  tmp=x;
  hdrdmfile=y;
  outfile=z;
  z=size(tmp,3);
  t=size(tmp,4);
end;

infid=fopen(hdrdmfile,'r');
if infid<3, error('Could not open in file!'); end;

hdrdminfo=getdmodinfo(infid);

disp('Reading header...');
fseek(infid,0,'bof');
hdr=fread(infid,hdrdminfo(1),'char');
fclose(infid);

disp(['Header size= ',int2str(length(hdr))]);

outfid=fopen(outfile,'w');
if outfid<3, error('Could not open out file!'); end;

disp('Writing header...');
fwrite(outfid,hdr,'char');
disp('Writing data...');
for m=1:z,
  disp(['Writing slice ',int2str(m),'...']);
  %for n=1:t,
    %for o=1:y, for p=1:x,
      if ~fwrite(outfid,squeeze(tmp(:,:,m,:)),'int16'),
        estr=printf('Could not write (%d,%d) to %s',m,n,outfile);
        error(estr);
      end;
    %end; end;
  %end;
end;
fclose(outfid);

if ~nargin
  clear tmp
else,
  f=tmp;
end;

