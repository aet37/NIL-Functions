function y=readge(filename,dim,offset,type)
% Usage ... y=readge(filename,dim,offset,type)
%
% By default read GE images (7904 bytes offset,
% 256x256 unsigned short images).

%fid=fopen(filename,'r');
fid=fopen(filename,'r','l');
if fid<3, error('Could not open file!'); end;

if nargin<4, type='short'; end;
if nargin<3, offset=9728; end; 	% previosly: 7904, 8432
if nargin<2, dim=[256 256]; end;

fsk=fseek(fid,offset,'bof');
if fsk~=0, error('Could not seek to offset!'); end;

[y,cnt]=fread(fid,dim,type);

shiftcols=0;
if (shiftcols),
  %y=abs(ifft2(fft2(y).*((ones(size(y,1),1)*cos(pi*[1:size(y,2)])).')));
  y=abs(ifft2(fft2(y).*((ones(size(y,1),1)*repmat([1 -1],1,size(y,2)/2)).')));
end;

fclose(fid);


