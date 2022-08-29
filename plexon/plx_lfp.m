function [timetable] = plx_lfp(filename, lfp_ch, durarray);
% plx_lfp(filename, lfp_ch, durarray) Read analog signals from a .plx file
% A function of show_lfp & show_lfp_woStimID.m
% 
% [timetable] = plx_lfp(filename, lfp_ch, durarray)
%
% INPUT:
%   filename - if empty string, will use File Open dialog
%   lfp_ch - 0-based external channel number
%   durarray - analysis time window (ms)
% 
% OUTPUT:
%   timetable - time stamps with the time window
% +++++++++++++++++++++++++++++++++++++++++++++++
% HISTORY
% +++++++++++++++++++++++++++++++++++++++++++++++
% 2003. Dec. 17 by Hiro

Event03 = 3;    % Stimulus onset

% get time stamp of stimulus onset
fprintf('%s', 'Reading time stamp of stim onset (PLEXON) ... ');
[freq, n_ev, ts, sv] = plx_event_ts1(filename, Event03);
ts_stim_on = ts./freq;  %sec
fprintf('Done\n');
fprintf('\n# Events= %d\n',n_ev);

% get LFP
fprintf('%s', 'Reading LFP (PLEXON) ... ');
[freq, adfreq, n, ts, fn, ad] = plx_ad1(filename, lfp_ch);
fprintf('Done\n');

timetable = [];
t=-1*durarray(1):1/(adfreq/1000):durarray(2);
timetable=t';
size(timetable);

fnlength = length(fn);
tslength = length(ts);
adlength = length(ad);
if fnlength~=tslength,
    fprintf('mismatched the number of fn & ts');    
    return;
end
keyboard,

fprintf('%s', 'Calculating time stamp of LFP ... ');
adctimestap = [];
for i=1:fnlength,
    tmpindx = 0;
    tmpindx = [tmpindx [1:fn(i)-1]./adfreq];
    tmpindx = tmpindx+ts(i);
    tmplen = length(tmpindx);
    adctimestap(tmplen*(i-1)+1:tmplen*i) = tmpindx;
    %adctimestap = [adctimestap tmpindx];
end
fprintf('Done\n');
keyboard,

fprintf('%s', 'Searching for LFP data point at stimulus onset ... ');
for i=1:n_ev,
    %onset = find(adctimestap >= ts_stim_on(i));
    onset = find(adctimestap <= ts_stim_on(i));
    istart = onset(length(onset)) - durarray(1)*(adfreq/1000);
    istop = onset(length(onset)) + durarray(2)*(adfreq/1000);
    timetable = [timetable ad(istart:istop)'];
end
fprintf('Done\n');

size(ad), size(adctimestamp), size(timetable),

