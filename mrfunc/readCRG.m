function f=readCRG(filename)
% Usage ... f=readCRG(filename)

fid=fopen(filename,'r');
if (fid<3), error('Could not open file!'); end;

fscanf('%s'
