function [i1,i2,i3]=getanalyzeinfo(filename)
% Usage ... [i1,i2,i3]=getanalyzeinfo(filename)
%
% 1) xdim
% 2) ydim
% 3) zdim
% 4) tdim

fid=fopen(filename,'r');
if fid<3, error('Could not open file'); end;

hdrsize=fread(fid,1,'int');
pad1=fread(fid,28,'char');
extents=fread(fid,1,'int');
pad2=fread(fid,2,'char');
regular=fread(fid,1,'char');
pad3=fread(fid,1,'char');
dims=fread(fid,1,'short');
xdim=fread(fid,1,'short');
ydim=fread(fid,1,'short');
zdim=fread(fid,1,'short');
tdim=fread(fid,1,'short');
pad4=fread(fid,20,'char');
datatype=fread(fid,1,'short');
bits=fread(fid,1,'short');
pad5=fread(fid,6,'char');
xsize=fread(fid,1,'float');
ysize=fread(fid,1,'float');
zsize=fread(fid,1,'float');
pad6=fread(fid,20,'char');
spmintensity=fread(fid,1,'float');
pad7=fread(fid,24,'char');
glmax=fread(fid,1,'int');
glmin=fread(fid,1,'int');
descr=fread(fid,80,'char');

fclose(fid);

i1=[xdim;ydim;zdim;tdim;datatype;bits;glmax;glmin];
i2=[xsize;ysize;zsize;spmintensity];
i3=[descr];

if nargout==0,
  disp(sprintf('xdim= %d',xdim));
  disp(sprintf('ydim= %d',ydim));
  disp(sprintf('zdim= %d',zdim));
  disp(sprintf('tdim= %d',tdim));
  disp(sprintf('datatype= %d',datatype));
  disp(sprintf('bits= %d',bits));
  disp(sprintf('glmax= %d',glmax));
  disp(sprintf('glmin= %d',glmin));
  disp(sprintf('xsize= %f',xsize));
  disp(sprintf('ysize= %f',ysize));
  disp(sprintf('zsize= %f',zsize));
  disp(sprintf('intensity= %f',spmintensity));
  disp(sprintf('description= %s',descr));
end;

% datatype=1 is char
% datatype=2 is short
% datatype=4 is long
% datatype=8 is a float
% datatype=16 is double
% datatype=32 is float with imaginary part

