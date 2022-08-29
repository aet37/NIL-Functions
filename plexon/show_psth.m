% show_psth.m
% 
% +++++++++++++++++++++++++++++++++++++++++++++++
% HISTORY
% +++++++++++++++++++++++++++++++++++++++++++++++
% original file: plx_ad
% 2003. Dec. 17 by Hiro

clear all;

Event257 = 257; % stimulus id order

% ========================================
% File open
% ========================================
filename ='';
if(length(filename) == 0)
   [fname, pathname] = uigetfile('*.plx', 'Select a plx file');
	filename = strcat(pathname, fname);
end

fid = fopen(filename, 'r');
if(fid == -1)
	disp('cannot open file');
   return
end

fprintf('%s\n', filename);


% get stimulus id
fprintf('%s', 'Reading stim ID (PLEXON) ... ');
[freq, n, ts, sv] = plx_event_ts1(filename, Event257);
fprintf('Done\n');

if sv ~= 0
% get number of trials per stimulus
for i=1:length(sv),
    if sv(i) <=128
        stim_id(i)=log2(sv(i))+1;
    else
        stim_id(i)=sv(i)-128;
        stim_id(i)=8+log2(stim_id(i))+1;
    end
end
tmp=stim_id(1);
n_trial=length(find(stim_id(1:n)==tmp));
n_stim=n/n_trial;

% get stimulus id order
table_pos = [];
for i=1:n_stim,
    %tmp=find(stim_id(1:n) == stim_id(i));
    tmp=find(stim_id(1:n) == i);
    table_pos=[table_pos, tmp'];
end
else
    n_stim = 1;
    stim_id = 1;
    n_trial = input('Number of trials: ');
    table_pos(1:n_trial) = 1:n_trial;
    table_pos = table_pos';
end

% get spike information
spk_ch = input('Spike channel (1-4) >> ');
unit = input('isolated (1-4), unisolated (0) >> ');
pre_t = input('pre time (ms): ');
post_t = input('post time (ms): ');
stim_dur = input('stimulus duraion (ms): ');
pre_t = pre_t/1000;   % conversion msec to sec
post_t = post_t/1000;   % conversion msec to sec
total_t = pre_t + post_t;
stim_dur = stim_dur/1000;   % conversion msec to sec
durarray = [pre_t post_t];
bin_width = input('bin width (msec) >> ');
bin_width=bin_width/1000;   % conversion msec to sec
durarray = [pre_t post_t];

psth_table = plx_psth(filename, spk_ch, unit, durarray, bin_width);

fprintf('Saving PSTH as text files ...')
all_psth=[];
for i=1:n_stim,
    psth=[];
    psth = [psth psth_table(:, 1)]; % time stamps
    for j=1:n_trial,
        psth=[psth psth_table(:, table_pos(j, i)+1)];
    end
    % calculate maen firing rate, spikes/s
    for k=1:size(psth,1),
        average(k) = (mean(psth(k, 2:(n_trial+1))))/bin_width;
    end
    psth = [psth average'];
    all_psth = [all_psth average'];
    max_spike_rate(i)=max(average);
    %filename = strcat('psth', num2str(stim_id(i)), '.txt');
    filename = strcat('psth', num2str(i), '.txt');
    dlmwrite(filename, psth);
end
fprintf(' Done\n');

% plot mean
h=figure;
for i=1:n_stim,
    for j=1:size(psth,1),
        x(j)=psth(1,1)+bin_width*(j-1);
    end
    subplot(n_stim, 1, i);
    plot(x,all_psth(:, i));
    %subplot(n_stim, 1, stim_id(i));
    %plot(x,all_psth(:, stim_id(i)));
    axis([psth(1,1) psth(size(psth,1),1) 0 max(max_spike_rate)])
    y=0:0.1:max(max_spike_rate);
    line(0, y,'color', 'r'); % stim on
    line(stim_dur, y,'color', 'r'); % stim off
    title(strcat('stim ID - ', num2str(i), '(Mean)'));
end
saveas(h, 'meanSpikeRate.jpg');
