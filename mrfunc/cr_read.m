function [a,b] = cr_read(filename,fs)
% Usage ... [a,b] = cr_read(filename,fs)


fid = fopen(filename,'r');
fseek(fid,0,'eof');
eof_pos=ftell(fid);
fseek(fid,0,'bof');

k=1;
offset=0;
while(offset<=eof_pos-8)
  a(k,1)=fread(fid,1,'int32');
  a(k,2)=fread(fid,1,'int16');
  a(k,3)=fread(fid,1,'int16');
  offset=ftell(fid);
  k=k+1;
  %disp([offset k eof_pos]);
end;

for m=1:length(a), b(m)=m/fs; end;

fclose(fid);
