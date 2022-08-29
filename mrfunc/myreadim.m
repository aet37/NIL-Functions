function y=readim(a,f,h)
% usage .. readim(a,f,h);
% displays matrix "a" is a string that names the input file
% and "f" is the optional size - default is [128 128]
% and "g" is the optional header size - default is 0 bytes

if exist('f') == 0, 
  f = [128 128];
end
if exist('h') == 0, 
  h = 0;
end

fid = fopen(a,'r');
y = fread(fid,f,'short');
fclose(fid);
