%Check_SamplingRate.m
clear all;

[freq, n_ev, ts, sv] = plx_event_ts1('C:\PlexonData\File1.plx', 3);
trig=ts/freq*1000; %msec

isi=diff(trig);
hist(isi);