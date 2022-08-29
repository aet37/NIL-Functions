function h=readrawheader(fname)
% usage ... h=readrawheader(fname)

fid=fopen(fname,'r','b');
if (fid<3), error('Could not open file!'); end;

%h=uint8(fread(fid,39940,'char'));
h=uint8(fread(fid,39940,'uint8'));

fclose(fid);


