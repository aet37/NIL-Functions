function [data,info] = my_plx_lfp(filename, trigid, lfp_ch, durarray)
% Usage ... [data,info] = my_plx_lfp(filename, trigid, lfpchannel, durarray)
% [data,info] = my_plx_event_ts(filename, trigid, lfp_channel, durarray)
%

% original file: plx_event_ts
% 2003. Dec. 17 by Hiro

if(length(filename) == 0)
   [fname, pathname] = uigetfile('*.plx', 'Select a plx file');
	filename = strcat(pathname, fname);
end

fid = fopen(filename, 'r', 'l');
if(fid == -1)
	disp(sprintf('Cannot open file %s',filename));
   return
end

disp(strcat('File= ', filename));

% read file header
header = fread(fid, 64, 'int32');
freq = header(35);  % frequency
ndsp = header(36);  % number of dsp channels
nevents = header(37); % number of external events
nslow = header(38);  % number of slow channels
npw = header(39);  % number of points in wave
npr = header(40);  % number of points before threshold
tscounts = fread(fid, [5, 130], 'int32');
wfcounts = fread(fid, [5, 130], 'int32');
evcounts = fread(fid, [1, 512], 'int32');

% skip variable headers 
fseek(fid, 1020*ndsp + 296*nevents + 296*nslow, 'cof');

% read the data
n=0;
icnt=0;
record = 0;
while feof(fid) == 0
    icnt=icnt+1;
    ii(icnt)=ftell(fid);
	type = fread(fid, 1, 'int16');
	upperbyte = fread(fid, 1, 'int16');
	timestamp = fread(fid, 1, 'int32');
	channel = fread(fid, 1, 'int16');
	unit = fread(fid, 1, 'int16');
	nwf = fread(fid, 1, 'int16');
	nwords = fread(fid, 1, 'int16');
	toread = nwords;
	if toread > 0
	  wf = fread(fid, toread, 'int16');
	end
   	if type == 4
         if sum(channel==ch)>0, 
 	        	n = n + 1;
         		ts(n) = timestamp;
				sv(n) = unit;
				nws(n) = nwords;
				chid(n) = channel;
      	end
   	end
    its(icnt)=timestamp;
    
    record = record + 1;
    if feof(fid) == 1
    	break
	end
   
end

disp(sprintf('# Events= %d',n));
keyboard,

for nn=1:n,


end
fclose(fid);

data=0;
info=0;