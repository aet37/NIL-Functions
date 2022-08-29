function [lfp,all_lfp,y,lfp_table]=show_lfp(filename,lfp_ch,pre_t,post_t,stim_dur,n_trial)
% Usage ... [lfp,all_lfp,y]=show_lfp(plxfilename,plxCH,pre_time,post_time,stim_dur,n_trials)

% show_lfp.m
% 
% +++++++++++++++++++++++++++++++++++++++++++++++
% HISTORY
% +++++++++++++++++++++++++++++++++++++++++++++++
% original file: plx_ad
% 2003. Dec. 17 by Hiro

if (nargin<1),
  no_input_flag=1;
else
  no_input_flag=0;
end;



Event257 = 257; % an stimulus id order

% ========================================
% File open
% ========================================

if (no_input_flag),
filename ='';
if(length(filename) == 0)
   [fname, pathname] = uigetfile('*.plx', 'Select a plx file');
	filename = strcat(pathname, fname);
end
end;

fid = fopen(filename, 'r');
if(fid == -1)
	disp('cannot open file');
   return
end

if (no_input_flag),
fprintf('%s\n', filename);
end;

% get stimulus id
fprintf('%s', 'Reading stim ID (PLEXON) ... ');
[freq, n, ts, sv] = plx_event_ts1(filename, Event257);
fprintf('Done\n');

if 1
% get number of trials per stimulus
for i=1:length(sv),
    if sv(i) <=128
        stim_id(i)=log2(sv(i))+1;
    else
        stim_id(i)=sv(i)-128;
        stim_id(i)=8+log2(stim_id(i))+1;
    end
end

%stim_id = [1,1,1,1,1,1,1,1,1,1];
%tmp = stim_id(1);
tmp=1;

n_trial=length(find(stim_id(1:n)==tmp));
%n_stim=n/n_trial;
n_stim=length(sv)/n_trial;

% get stimulus id order
table_pos = [];
for i=1:n_stim,
    tmp=find(stim_id(1:length(sv)) == stim_id(i));
    table_pos=[table_pos, tmp'];
end
else
    n_stim = 1;
    stim_id = 1;
    if (no_input_flag),
    n_trial = input('Number of trials: ');
    end;
    table_pos(1:n_trial) = 1:n_trial;
    table_pos = table_pos';
end

% get LFP information
if (no_input_flag),
lfp_ch = input('LFP channel (0 base) >> ');
pre_t = input('pre time (ms): ');
post_t = input('post time (ms): ');
stim_dur = input('stimulus duraion (ms): ');
end;
total_t = pre_t + post_t;
durarray = [pre_t post_t];

lfp_table = plx_lfp(filename, lfp_ch, durarray);

%fprintf('Saving LFP as text files ...')
all_lfp=[];
disp(sprintf(' # stimuli= %d   # trials= %d',n_stim,n_trial));
for i=1:n_stim,
    lfp = [lfp lfp_table(:, 1)]; % copy time stamps
    for j=1:n_trial,
        lfp=[lfp lfp_table(:, table_pos(j, i)+1)];
    end
    % calculate maen LFP
    for k=1:size(lfp,1),
        average(k) = mean(lfp(k, 2:(n_trial+1)));
    end
    lfp = [lfp average'];
    all_lfp = [all_lfp average'];
    max_lfp(i)=max(average);
    min_lfp(i)=min(average);
    if (nargout==0),
      filename = strcat('lfp', num2str(stim_id(i)), '.txt');
      dlmwrite(filename, lfp);
    end;
end

y=min(min(all_lfp)):max(max(all_lfp));

if (nargout==0),
% plot mean
h=figure;
for i=1:n_stim,
    subplot(n_stim, 1, i);
    plot(lfp(:, 1),all_lfp(:, i));
    line(stim_dur, y,'color', 'r'); % stim off
    grid on;
    title(strcat('Stim ID-', num2str(i), '(Mean)'));
end
%saveas(h, 'meanLFP.jpg');

% plot individual
if sv == 0
h=figure;
for i=1:n_trial,
    subplot(n_trial, 1, i);
    plot(lfp(:, 1),lfp(:, i+1));
    line(stim_dur, y,'color', 'r'); % stim off
    grid on;
    title(strcat('Trial-', num2str(i)));
end
%saveas(h, 'trialsLFP.jpg');
end
end;

