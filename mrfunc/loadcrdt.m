function out=loadcrdt(file)
%
% Usage ... out = loadcrdt(file)
%
%

fid=fopen(file);
temp=fscanf(fid,'%f');
fclose(fid);

out=temp;
