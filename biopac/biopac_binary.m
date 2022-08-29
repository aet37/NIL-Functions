% biopac_binary.m 
% 
% #AS156 - AcqKnowledge File Format for Windows/PC Updated Updated 060805 
% http://www.biopac.com/AppNotes/app156FileFormat/FileFormat.htm 
%  
% Simple m-file for loading samples of named channels from AcqKnowledge ACQ files.  
% Jesper G Ansson 
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=4989&objectType=file 
%  
% MatLab R13 
% 2006.07.04 Modified by Hiro 
% 2006.07.05 minor changes 
 
 
clear all; 
clc; 
 
filename = ''; 
if(length(filename) == 0) 
   [fname, pathname] = uigetfile('*.ACQ', 'Select a BioPac file'); 
	i_filename = strcat(pathname, fname); 
end 
 
fprintf('%s\n', i_filename); 
 
fid = fopen(i_filename, 'r','l'); 
if(fid == -1) 
	disp('cannot open file'); 
   return 
end 
 
% short = int16 
% long = int32 
% double = double 
 
% ### Graph header section ### 
nItemHeaderLen = fread(fid, 1, 'int16');    % Not currently used 
% 39 = version of Acq 3.7.3 or above (Win 98, 98SE, 2000, Me, XP) 
lVersion = fread(fid, 1, 'int32');           % File version identifier 
if lVersion == 38 
    fprintf('Version of Acq 3.7.0-3.7.2 (Win 98, 98SE, NT, Me, 2000)\n'); 
elseif lVersion == 39 
    fprintf('Version of Acq 3.7.3 or above (Win 98, 98SE, 2000, Me, XP)\n'); 
else 
    fprintf('This program will not work properly!\n'); 
    break; 
end 
        
lExtItemHeaderLen = fread(fid, 1, 'int32');  % Extended item header length 
nChannels = fread(fid, 1, 'int16');          % Number of channels stored 
nHorizAxisType = fread(fid, 1, 'int16');     % Horizontal scale type, one of the  following; 0 = Time in seconds, 1 = Time in HMS format, 2 = Frequency, 3 = Arbitray 
fseek(fid, 16, 'bof'); 
dSampleTime = fread(fid, 1, 'double');        % The number of milliseconds per sample 

disp(sprintf('  # Channels= %d',nChannels));
disp(sprintf('  Sample Time= %f',dSampleTime));
 
% ### Per Channel Data Section ### 
sectionstart = lExtItemHeaderLen;             
fseek(fid, sectionstart, 'bof'); 
lChanHeaderLen = fread(fid, 1, 'int32');     % Length of channel header. 
if lVersion == 38 
    fseek(fid, sectionstart+88, 'bof');      % I think this is correct 
elseif lVersion == 39 
    fseek(fid, sectionstart+88, 'bof'); 
else 
    fprintf('This program will not work properly!\n'); 
end 
 
lBufLength = fread(fid, 1, 'int32');         % Number of data samples 
for i=1:nChannels 
    sectionstart = lExtItemHeaderLen + (i-1)*lChanHeaderLen; 
    fseek(fid, sectionstart+4, 'bof');        
    nNum(i) = fread(fid, 1, 'int16');               % Channel number 
    szCommentText(i,1:40) = fscanf(fid, '%40c', 1); % Channel label 
    fseek(fid, sectionstart+68, 'bof'); 
    szUnitsText(i,1:20) = fscanf(fid, '%20c', 1);   % Units text 
    fseek(fid, sectionstart+92, 'bof'); 
    dAmplScale(i) = fread(fid, 1, 'double');        % Units/count 
    dAmplOffset(i) = fread(fid, 1, 'double');       % Units 
end 
 
% ### Foreign Data Section ### 
fseek(fid, lExtItemHeaderLen+lChanHeaderLen*nChannels, 'bof'); 
nLength = fread(fid, 1, 'int16');    % Total length of foreign data packet. 
 
% ### Per Channel Data Types Section ### 
% This block is repeated for as many channels that were detected in the graph header packet nChannels field. 
sectionstart = lExtItemHeaderLen + lChanHeaderLen*nChannels + nLength; 
fseek(fid, sectionstart, 'bof'); 
for i=1:nChannels 
    nSize(i) = fread(fid, 1, 'int16'); 
    nType(i) = fread(fid, 1, 'int16'); 
end 
choffset = cumsum([0 nSize(1:end-1)]);  % Interleave offset 
 
% ### Channel Data Section ### 
% The individual channel data is stored after the Per Channel Data Types Section.  
% The channel data is in an interleaved format. 
% Read samples, one channel at a time. 
fprintf('\n%s\n\n', 'Reading data... ' ); 
 
chindex = 1:nChannels; 
 
sectionstart = lExtItemHeaderLen + lChanHeaderLen*nChannels + nLength + 4*nChannels; 
fseek(fid, sectionstart, 'bof'); 
blocksize = sum(nSize); 
for k=1:nChannels, 
    fseek(fid, sectionstart + choffset(chindex(k)), 'bof'); 
    switch nType(chindex(k)) 
        case 1  % double 
            varargout(k) = {fread(fid, lBufLength, 'double', blocksize-8)}; 
        case 2  % int 
            varargout(k)= {dAmplScale(chindex(k)) * fread(fid, lBufLength, 'int16', blocksize-2) + ...  
                                    dAmplOffset(chindex(k))}; 
    end 
end 
fclose(fid); 

 
 
% $$$$$$$$$$$$$$$$$$$$$$$$$$$ Analysis $$$$$$$$$$$$$$$$$$$$$$$$$$$ 
% Display channel information, Note actual channel number is different. 
for i = 1:length(nNum), 
    fprintf('Ch %2d: %s\n', i, szCommentText(i,1:40)); 
end 
fprintf('\n'); 
 
% -- Detect the edge of trigger pulses --------------------------- 
THRESHOLD=1.0;  %0.008;% To detect TTL puls positive edge 
 
c_num=input('STIM ON Ch #: '); 
edge_pos = find(diff(varargout{c_num}) > THRESHOLD); 
n_edges = length(edge_pos); 
fprintf('Number of pulses: %d\n', n_edges); 
offset=input('Skip first N pulses (N = 0?): '); 
offset = offset +1; 
n_blanks=input('Read data every N pulses (N = 1?): '); 
 
% calculating number of blocks 
n_trials=offset:n_blanks:n_edges; 
fprintf('Number of trials: %d\n', length(n_trials)); 
 
fprintf('Inter-puls interval (on-to-on): %d ms: \n', (edge_pos(2) - edge_pos(1))*dSampleTime); 
 
% Recording duration relative to the trig pulses 
pre_len=input('\nPre recording time (ms): '); 
pre_len=pre_len/dSampleTime; 
post_len=input('Post recording time (ms): '); 
post_len=post_len/dSampleTime; 
total_len=pre_len+post_len; 
while total_len > edge_pos(2) - edge_pos(1), 
    fprintf('\n### - Duration is longer than the inter-pulse interval - ###\n'); 
    fprintf('Input again !!\n\n'); 
    pre_len=input('\nPre recording time (ms): '); 
    pre_len=pre_len/dSampleTime; 
    post_len=input('Post recording time (ms): '); 
    post_len=post_len/dSampleTime; 
    total_len=pre_len+post_len; 
end 
TimeStamp = pre_len*-dSampleTime:dSampleTime:post_len*dSampleTime; 
 
while 1, 
    fprintf('--------------------------------\n'); 
    for i = 1:length(nNum), 
        fprintf('Ch %2d: %s\n', i, szCommentText(i,1:40)); 
    end 
    fprintf('\n'); 
    fprintf('--------------------------------\n'); 
    ch=input('Target Ch #. (if 99, exit):  '); 
    if ch==99, break; end 
    figure; plot(varargout{ch}); Title('Whole recording period'); 
    fprintf('\n%s', 'Processing ... '); 
     
    out=[]; 
    out = TimeStamp'; 
    h1 = figure; 
    for n=1:n_edges, 
        % e.g.            pre_len          on      post_len 
        %      +  +  +  +  +  +  +  +  +  + x + + + + + + + + + + 
        %    -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 
        %out = [out, varargout{ch}((edge_pos(n)-pre_len-1):(edge_pos(n)+post_len-1))]; 
        out = [out, varargout{ch}((edge_pos(n)-pre_len):(edge_pos(n)+post_len))]; 
        subplot(5,ceil(n_edges/5), n); plot(out(:,n+1)); 
    end 
    mean_out = mean(out(:,2:size(out, 2))'); 
    h2 = figure; plot(out(:,1), mean_out); axis([out(1, 1) out(size(out,1), 1) min(mean_out) max(mean_out)]); Title('Mean'); xlabel('msec'); 
    fprintf('Done\n'); 
     
    fprintf('\n%s', 'Saving as Text ... '); 
    saveas(h1, strcat(sprintf('AllRuns_%s', szCommentText(ch,1:40)), '.jpg')); 
    saveas(h2, strcat(sprintf('Mean_%s', szCommentText(ch,1:40)), '.jpg')); 
    dlmwrite(strcat(sprintf('%s', szCommentText(ch,1:40)), '.txt'), out, '\t'); 
     
    fprintf('Done\n'); 
    fprintf('Continue ...? then Press Return\n'); pause; clc; 
end 
