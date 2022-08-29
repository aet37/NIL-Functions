function [psth_table] = plx_psth(filename, spk_ch, unit, durarray, bin_width);
% [psth_table] = plx_psth(filename, spk_ch, unit, durarray, bin_width): Read spike data from a .plx file
%
% [freq, adfreq, n, ts, fn, ad] = plx_ad(filename, ch)
%
% INPUT:
%   spk_ch: a channel for spikes (1 - 16)
%   unit: unit number (0: unsorted, 1-4: sorted)
%   bin_width: msec
% OUTPUT:
%   psth_table:
% 
% +++++++++++++++++++++++++++++++++++++++++++++++
% HISTORY
% +++++++++++++++++++++++++++++++++++++++++++++++
% original file: plx_ad
% 2003. Dec. 17 by Hiro

Event03 = 3;    % Stimulus onset

% check recording duration
start=durarray(1);
stop=durarray(2);
rec_tm=min(stop+start);
n_bin_pre = fix(start/bin_width);
n_bin_post = fix(stop/bin_width);
tn_bin=n_bin_pre+n_bin_post;

% check pre stim & post pre stim duration
fprintf('%s', 'Reading time stamp of stim onset (PLEXON) ... ');
[freq, n_ev, ts, sv] = plx_event_ts1(filename, Event03);
ts_stim_on=ts/freq; %sec
fprintf('Done\n');
%--

% generate time stamp from stim onset
psth_table = [];
warning off MATLAB:colon:operandsNotRealScalar;
psth_table=[psth_table (-1*(n_bin_pre-1)*bin_width:bin_width:n_bin_post*bin_width)'];

% generate PSTH
fprintf('%s', 'Reading time stamp of spike onset (PLEXON) ... ');
[n, ts_spike] = plx_ts1(filename, spk_ch, unit);
fprintf('Done\n');

fprintf('\n%s', 'Generating PSTH ... ');
for i=1:n_ev,
    psth = [];
    % pre stim
    for t=1:n_bin_pre,
        tmp=find(((ts_stim_on(i)-bin_width*t) <= ts_spike)&(ts_spike < (ts_stim_on(i)-bin_width*(t-1))));
        n_spikes=length(tmp);
        psth = [psth n_spikes];
    end
    % post stim
    for t=1:n_bin_post,
        tmp=find(((ts_stim_on(i)+bin_width*(t-1)) <= ts_spike)&(ts_spike < (ts_stim_on(i)+bin_width*t)));
        n_spikes=length(tmp);
        psth = [psth n_spikes];
    end
    psth_table = [psth_table psth(1:tn_bin)'];
end
fprintf('Done\n');
