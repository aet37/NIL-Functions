
% info to specify: root, extension, fstart, fend, id

o=1;

for m=fstart:fend,

  filename=[root,int2str(m),extension];
  fid=fopen(filename,'r');
  if (fid<3) error('Could not open file!'); end;

  eval(['spins_n_',id,'(o)=fread(fid,1,'''int''');']);
  eval(['perts_n_',id,'(o)=fread(fid,1,'''int''');']);
  eval(['totalsignal_',id,'(o)=fread(fid,1,'''double''');']);
  o=o+1;

  fclose(fid);
  clear fid

end;

clear m n o

