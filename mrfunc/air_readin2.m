function [regval]=air_readin2(xdim,ydim,nim,nsl,firstim)
% Usage ... [regval]=air_readin2(xdim,ydim,nim,nsl,firstim)
%
% Reads in image information in air format and puts
% it into an array, with format xdim,ydim,image,slice
% 
%	nim = number of images
%	nsl = number of slices
%
% Assumptions: All files begin with 'func_0'

if nargin<5,
  firstim=1;
end;

%bstr = 'func_0';
%estr = '.img';

regval = zeros(xdim,ydim,nim,nsl);

for i= (firstim):(nim+firstim-1)

        fstr=sprintf('func_%04d.img',i);

	%if (i<10)
	%   fstr = [bstr,'00',int2str(i),estr];
	%elseif (i<100)
	%   fstr = [bstr,'0',int2str(i),estr];
	%else
	%   fstr = [bstr,int2str(i),estr];
	%end;
        %disp(i);
        %disp(fstr);

	tmpfid = fopen(fstr,'r');
        if tmpfid<3,
          estr=sprintf('Could not open file %s',fstr);
          error(estr); 
        end;
	
	for j=1:nsl
	  regval(:,:,(i+1),j) = fread(tmpfid,[xdim ydim],'int16');
	end;

	fclose(tmpfid);
end; 

