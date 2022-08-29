function [img,hdr] = fdf(fdfname)
% Usage ... img = fdf(fdf_fname)
%
% m-file that can open Varian FDF imaging files in Matlab.

%
% Shanrong Zhang
% Department of Radiology
% University of Washington
% 
% email: zhangs@u.washington.edu
% Date: 12/19/2004
% 
% Fix Issue so it is able to open both old Unix-based and new Linux-based FDF
% Date: 11/22/2007
%

% Modified by Alberto Vazquez


warning off MATLAB:divideByZero;

if (nargin==0),
  [filename pathname] = uigetfile('*.fdf','Please select a fdf file');
  fdfname=sprintf('%s%s',filename,pathname);
end;

[fid] = fopen(fdfname,'r');

num = 0;
done = false;
machineformat = 'ieee-be'; % Old Unix-based  
line = fgetl(fid);
hdr{1}=line; %disp(line);
while (~isempty(line) && ~done)
    line = fgetl(fid);
    hdr{num+2}=line; %disp(line)
    if strmatch('int    bigendian', line),
        machineformat = 'ieee-le'; % New Linux-based    
    end
    
    if strmatch('float  matrix[] = ', line)
        [token, rem] = strtok(line,'float  matrix[] = { , };');
        M(1) = str2num(token);
        tmpfound = 0; tmpcnt = 2;
        while (~tmpfound),
            [token, rem] = strtok(rem,', };');
            M(tmpcnt) = str2num(token);
            if strcmp(rem,'};'), 
                tmpfound = 1; 
            else, 
                tmpcnt = tmpcnt + 1; 
            end;
        end;
        %M(2) = str2num(strtok(rem,', };'));
        %token, rem,
    end
    if strmatch('float  bits = ', line)
        [token, rem] = strtok(line,'float  bits = { , };');
        bits = str2num(token);
    end

    num = num + 1;
    
    if num > 41
        done = true;
    end
end

%skip = fseek(fid, -M(1)*M(2)*bits/8, 'eof');
%img = fread(fid, [M(1), M(2)], 'float32', machineformat);
%img = img';

skip = fseek(fid, -prod(M)*bits/8, 'eof');

if length(M)==2, M(3)=1; end;
for mm=1:M(3),
  img(:,:,mm) = fread(fid, [M(1) M(2)], 'float32', machineformat);
end;
img=squeeze(img);

fclose(fid);

if (nargout==0),
  imshow(img, []); 
  colormap(gray);
  axis image;
  axis off;
  %disp(hdr);
end;

% end of m-code

