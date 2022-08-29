function f=makedmod(tmp,hdrdmfile,outfile)
% Usage ... f=makedmod(f,hdrdmfile,outfile)
%
% Writes a dmodfile with the header from the hdrdmfile.
% The data to write, f, is organized in x,y,t,z.

t=size(tmp,3);
z=size(tmp,4);

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
      if ~fwrite(outfid,squeeze(tmp(:,:,:,m)),'int16'),
        estr=printf('Could not write (%d) to %s',m,outfile);
        error(estr);
      end;
    %end; end;
  %end;
end;
fclose(outfid);
  
clear tmp

f=1;
