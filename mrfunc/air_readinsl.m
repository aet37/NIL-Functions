function [regval]=air_readin(xdim,ydim,nim,nsl)
% Usage ... [regval]=air_readin(filename,nim,nsl)
%
% Reads in image information in air format and puts
% it into an array, with format xdim,ydim,image,slice
% 
%	nim = number of images
%	nsl = number of slices


bstr = 'func_00';
estr = '.img';

regval = zeros(xdim,ydim,nim,nsl);

for i= 1:nim

	if (i<10)
	   fstr = [bstr,'00',int2str(i),estr];
	elseif (i<100)
	   fstr = [bstr,'0',int2str(i),estr];
	else
	   fstr = [bstr,int2str(i),estr];
	end;

	tmpfid = fopen(fstr,'r');
	
	for j=1:nsl
	  regval(:,:,i,j) = fread(tmpfid,[64 64],'int16');
	end;

	fclose(tmpfid);
end; 
