function [f,a,b]=pread(filename,offset,nitems)
% Usage ... [f,a,b]=pread(filename,offset,nitems)
%
% Reads nitems for filename in short format after
% offset of offset bytes. The data is assumed complex
% in this function and alternating real, imaginary.

% sample: [f,freal,fimag]=pread('P12800.7',39984,2*64*64)

fileid=fopen(filename,'r');
if fileid<3,
  error('Could not open file!');
end;

filestatus=fseek(fileid,offset,'bof');
if filestatus,
  error('Could not seek to offset location!');
end;

[data,datacount]=fread(fileid,nitems,'short');
if datacount~=nitems,
  error('Could not read nitems from file (as shorts)');
end;

filestatus=fclose(fileid);
if filestatus,
  error('Could not close file!');
end;

a=zeros([nitems/2 1]);
b=zeros([nitems/2 1]);
f=zeros([nitems/2 1]);
for m=1:nitems/2,
  a(m)=data(2*m-1);
  b(m)=data(2*m);
  f(m)=a(m)+i*b(m);
end;

if nargout==0,
  plot([1:length(a)]',a,[1:length(b)]',b)
  clear f
end;

