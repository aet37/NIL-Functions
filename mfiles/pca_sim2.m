%% Start clean
%
clear all
close all


%% Make waveforms y1, y2 and y12
%  essentially design two events or waveforms
%  y1 and y2
%  and their summation y12
%  we will use this to make two neuron waveforms y1 and y12

i1 = pi*[0:20]'/20;

y1 = [zeros(10,1); -sin(i1); zeros(length(i1)+10,1)];
y2 = [zeros(10+length(i1),1); sin(i1); zeros(length(y1)-10-2*length(i1),1)];

ii = [0:length(y1)-1];

%y1=(ii-30)*0.05;
%y2=((ii-30)*0.05).^2-1;

y12 = y1 + y2;

%y1=sign(y1);
%y12=sign(y12);

% plot waveforms y1 y2 y12
figure(1), clf,
subplot(211),
plot(ii, y1), axis tight, grid on, ylim([-1 1]),
xlabel('Index #'), ylabel('Y1'),
subplot(212),
plot(ii, y12), axis tight, grid on, ylim([-1 1]),
xlabel('Index #'), ylabel('Y12'),


%% Make a data stream
%  based on
%  nev - # events
%  ps  - spacing between events
%  ss  - their actual location (running sum)
%  p1  - prob for which one

nev = 200;
ps = 250 + round(50*randn(nev,1));
ss = 250 + cumsum(ps);
p1 = randn(nev,1);

data=zeros(250*nev+10*nev,1);
for mm=1:length(ss),
  if p1(mm)>0,
    %y_combined(ss(mm)+[1:length(y1)]-10)=1.0*(1+0*0.05*p1(mm))*y12;
    data(ss(mm)+[1:length(y12)]-10)=1.0*y12;
  else,
    %y_combined(ss(mm)+[1:length(y1)]-10)=(1-0*0.05*p1(mm))*y1;
    data(ss(mm)+[1:length(y1)]-10)=1.0*y1;
  end;
end;

% make a fake time vector
tt = [0:length(data)-1]/10000;

% create the data stream and add noise 
noise = 0.02*randn(length(data), 1);
data = data + noise;

% plot the generated data stream
figure(2),
subplot(211), plot(tt, data), axis tight, grid on,
xlabel('Time (sec)'), ylabel('Amplitude'),
subplot(212), plot(tt, data), axis tight, grid on, 
xlim([1 2]),
xlabel('Time (sec)'), ylabel('Amplitude'),


%% Make raster plot
%

thr = -0.5;

% threshold data and get indeces, then make sure each event is a single
% index
data_raster = zeros(length(data), 1);
data_raster_i = find(data < thr);
data_raster_i = [data_raster_i(1); data_raster_i(find(diff(data_raster_i)>=2)+1)];
data_raster (data_raster_i) = 1;


% plot the raster of data
figure(3), clf, 
subplot(221), plot(tt, data), axis tight, grid on,
xlabel('Time (sec)'), ylabel('Amplitude'),
subplot(222), plot(tt, data), axis tight, grid on, 
xlim([1 1.4]),
xlabel('Time (sec)'), ylabel('Amplitude'),
subplot(223), plot(tt, data_raster), axis tight, grid on,
xlabel('Time (sec)'), ylabel('Raster'),
subplot(224), plot(tt, data_raster), axis tight, grid on, 
xlim([1 1.4]),
xlabel('Time (sec)'), ylabel('Raster'),


%% Get snippets from the data based on the raster result
%  establish the number of snippets (n_snips)
%  and compile the snippet matrix for sorting (snips- time x snip#)
%
n_snips = length(data_raster_i);
snips = zeros(length(ii), n_snips);
for mm = 1:n_snips,
    snips(:,mm) = data( data_raster_i(mm) + [1:length(ii)] - 10 );
end;

% make a fake time vector
tsnip = ([1:length(ii)] - 10)/10000;

% pile plot for all
figure(4), clf,
plot(tsnip, snips, 'Color', [0.5 0.5 0.5]),
hold('on'), plot(tsnip, mean(snips,2), 'k', 'LineWidth', 2), hold('off'),
axis tight, grid on,
xlabel('Time (sec)'), ylabel('Amplitude'), 
title('Pile Plot'),


%% PCA
%

[U,S,W] = svd(snips);

% plot the first four components or eigenvectors
figure(5), clf,
subplot(221), plot(U(:,1)), axis tight, grid on,
subplot(222), plot(U(:,2)), axis tight, grid on,
subplot(223), plot(U(:,3)), axis tight, grid on,
subplot(224), plot(U(:,4)), axis tight, grid on,

% plot the coefficients for components 1, 2 and 3
figure(6), clf,
subplot(221), hist(W(:,1), 20),
ylabel('Counts'), xlabel('W1'),
subplot(222), hist(W(:,2), 20),
ylabel('Counts'), xlabel('W2'),
subplot(223), plot(W(:,1),W(:,2),'x')
xlabel('W1'), ylabel('W2'), grid on,
subplot(224), plot(W(:,1),W(:,3),'o'), 
xlabel('W1'), ylabel('W3'), grid on,


%% K-means cluster of PCA results
%

[K_W12, K_W12_center] = kmeans( [W(:,1) W(:,2)], 2);

[K_W12, K_W12_center] = kmeans( snips, 2, 'correlation');


k1i = find(K_W12 == 1);
k2i = find(K_W12 == 2);

% plot the clustered coefficients
figure(7), clf,
plot( W(k1i,1), W(k1i,2), 'bx' , W(k2i,1), W(k2i,2), 'ro'),
hold on, 
plot( K_W12_center(1,1), K_W12_center(1,2), 'kx', 'LineWidth', 3),
plot( K_W12_center(2,1), K_W12_center(2,2), 'ko', 'LineWidth', 3),
hold off,
grid on,
xlabel('W1'), ylabel('W2'),
title('K-means Clustered PCA W1 and W2')


% pile plot of each cluster
figure(8),
subplot(211), plot(tsnip, snips(:, k1i), 'Color', [0.5 0.5 0.5]),
hold on, plot(tsnip, mean(snips(:,k1i),2), 'b', 'LineWidth', 2), hold off,
grid on, axis tight,
xlabel('Time (sec)'), ylabel('Amplitude'),
title('Pile Plot of Cluster #1'),
subplot(212), plot(tsnip, snips(:, k2i), 'Color', [0.5 0.5 0.5]),
hold on, plot(tsnip, mean(snips(:,k2i),2), 'r', 'LineWidth', 2), hold off,
grid on, axis tight,
xlabel('Time (sec)'), ylabel('Amplitude'),
title('Pile Plot of Cluster #2'),


% relabel the raster plot after clustering
data_raster1 = zeros(size(data_raster));
data_raster2 = zeros(size(data_raster));

data_raster1( data_raster_i(k1i) ) = 1;
data_raster2( data_raster_i(k2i) ) = 2;

% plot the data and raster plot of each cluster
figure(9), clf,
subplot(221), plot(tt, data), axis tight, grid on, 
xlabel('Time (sec)'), ylabel('Amplitude'),
xlim([1 1.4]),
subplot(222), plot(tt, data), axis tight, grid on, 
xlabel('Time (sec)'), ylabel('Amplitude'),
xlim([1 1.4]),

subplot(223), plot(tt, data_raster1, 'b'), axis tight, grid on,
xlabel('Time (sec)'), ylabel('Raster 1'),
xlim([1 1.4]),
subplot(224), plot(tt, data_raster2, 'r'), axis tight, grid on, 
xlim([1 1.4]),
xlabel('Time (sec)'), ylabel('Raster 2'),


%% Auto-correlation
%

acorr_raster = xcorr(data_raster);
acorr_raster1 = xcorr(data_raster1);
acorr_raster2 = xcorr(data_raster2);
t_acorr = [1:length(acorr_raster)]-length(data_raster)+1;
t_acorr = t_acorr/10000;

% plot the autocorrelation of all the data, the autocorrelation of the 
% clustered data and the original time separation for comparison
figure(10), clf,
subplot(221), plot(t_acorr, acorr_raster), axis tight, grid on, xlim([-3 3]), ylim([0 10]),
subplot(222), plot(t_acorr, acorr_raster1), axis tight, grid on, xlim([-3 3]), ylim([0 10]),
subplot(223), plot(t_acorr, acorr_raster2), axis tight, grid on, xlim([-3 3]), ylim([0 20]),
subplot(224), hist(ps, 20), xlim([0 500]),


