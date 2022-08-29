function f=getdmodinfo(filename),
% Usage ... f=getdmodinfo(filename)
% This function retrieves the esential data from a
% DMOD file header. The filame or file-fid may be
% entered as function parameter. The ouput vector
% returns the following information:
% 1) first-image-location
% 2) xdim
% 3) ydim
% 4) zdim
% 5) tdim
% 6) pixtype
% 7) nslices
% 8) nvolumes


FIRST_REC_LOCATION=396;
DMOD_INFO_LOCATION=496;

if isstr(filename),
  dmodfid=fopen(filename,'r');
else,
  dmodfid=filename;
end;

tmpstatus=fseek(dmodfid,FIRST_REC_LOCATION,'bof');
if tmpstatus, error('Invalid Record location!'); end;
first_rec=fread(dmodfid,1,'int32');
tmpstatus=fseek(dmodfid,DMOD_INFO_LOCATION,'bof');
if tmpstatus, error('Invalid DMOD_INFO location!'); end;
dmod_info=fread(dmodfid,7,'int32');

if isstr(filename),
  fclose(dmodfid);
end;

f=[first_rec;dmod_info];
