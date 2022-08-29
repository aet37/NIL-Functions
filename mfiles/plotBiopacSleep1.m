function plotBiopacSleep1(bio,parms)
% Usage ... plotBiopacSleep1(bio,parms)

tt=[1:size(bio.EEG)]/1000;

clf,
subplot(511), plot(tt,bio.EEG), axis tight, grid on,
ylabel('EEG (mV)'), xlabel('Time (s)'),
subplot(512), plot(tt,bio.ECG), axis tight, grid on,
ylabel('EMG (mV)'), xlabel('Time (s)'),
subplot(513), plot(tt,bio.FLUX), axis tight, grid on,
ylabel('FLUX'), xlabel('Time (s)'),
subplot(514), plot(tt,bio.TB), axis tight, grid on,
ylabel('TB'), xlabel('Time (s)'),
subplot(515), plot(tt,bio.MainCam), axis tight, grid on,
ylabel('MainCam'), xlabel('Time (s)'),

