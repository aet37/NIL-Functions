clear all; close all; clc; tic;

% Start a pool of workers if one is not already running
% if ~matlabpool('size')
%     matlabpool open
% end

% Default options for variable name of spike data.  If these are in the
% file, it doesn't prompt you and just uses them to analyze.
spikedatafields = {'STRM', 'fSig'};

% Undo RTCAR & add offline CAR (1 = undo, 0 = leave)
CARundo = 1;
CARadd = 0;

% Noise multiplier level (i.e. 6*SD for noise)
stdmult = 6;

% Theshold for spike detection in SD's
detthresh = 3.5;
snrthresh = 1;
fcmthresh = 0.8;

% Option to detect spikes with a large positive deflection with
% insufficient negative to cross threshold.  Set to 1 to detect.
positivespikes = 0;

%The current program is set so that maxunits must be at least 3.
maxunits = 7;

%Set this to 1 to plot all clusters, or 0 to only plot counted ones.
allclusters = 0;

% Set default filter cutoffs
lfplowfreq = 1;
lfphighfreq = 100;
spikelowfreq = 300;
spikehighfreq = 5000;

% Amount to decimate LFP data from original sampling rate for plotting
lfpdec = 10;

% Spike window duration in seconds
window = .0024;

% Time to start using the data (eliminate transients from turnon)
starttime = 3;

% Initialize Figure Properties (set savefigs to 1 if save, 0 if not).
savefig = 0;
savetif = 1;
saveeps = 0;
set(0,'DefaultFigureWindowStyle','docked');
rect = [0.25, 0.25, 10.5, 8];
plotColor = ['b','g','r','c','m','y','k'];
plotMarker = ['o','x','s','d','*','p','h','+'];

% Initialize some variables
spikedatafield = [];
intscale = 1e7;

% Pick the file to analyze
[fnames, file.pathname] = uigetfile('*.mat', 'Select Files', 'MultiSelect', 'on');
if file.pathname
    cd(file.pathname)
    if iscell(fnames)
        file.fname = sort(fnames);
    else
        file.fname = sort({fnames});
    end
    
else
    disp('No File Selected')
    break
end
clear fnames

% Check for Analysis directory or create one
if ~isdir('Analysis')
    mkdir('Analysis')
end
file.savepath = [file.pathname 'Analysis'];

for multifile = 1:numel(file.fname)
    
    % Clear previous run figures and data if present
    clear data
    close all
    
    load([file.pathname file.fname{multifile}])
    
    if ~ischar(spikedatafield)
        % spikedatafields contains preset options for streamed spike data
        spikedataindexes = isfield(data, spikedatafields);
        
        % Determine field containing spike data with error checking
        if sum(spikedataindexes)
            spikedatafield = char(spikedatafields(spikedataindexes));
        else
            if isfield(data, 'eventnames')
                temp = data.eventnames;
            else
                temp = fieldnames(data);
            end
            [tempselect,ok] = listdlg('PromptString','Select the Variable with you data','ListString',temp, 'SelectionMode', 'single');
            if ok
                spikedatafield = temp{tempselect};
            else
                h = warndlg('No Variable selected');
                close(1);
                return
            end
            clear ok tempselect temp
        end
    end
    
    % Convert integer data to float if necessary on the first iteration of
    % the loop.  Does not support mixed int and float in same analysis
    % bunch.  
    if multifile == 1
        if isinteger(data.(spikedatafield).data{1})
            scalebutton = questdlg('Is the scale factor of your integer data 1e7?','Integer Conversion Factor');
            switch scalebutton
                case 'Yes'
                    intscale = 1e7;
                case 'No'
                    tempans = inputdlg('Enter your scale factor - Must be >1');
                    intscale = str2double(tempans);
                    if isnan(intscale)
                        disp('Invalid Number - Canceling Program')
                        break
                    end
                case 'Cancel'
                    disp('Canceling Program')
                    break
            end
        else
            % Sets this to 1 to not affect floating data
            intscale = 1;
        end
    end
    
    % Determine number of channels in data
    numchan = numel(data.(spikedatafield).data);
    
    %Round sampling rate
    samprate = round(data.(spikedatafield).samprate);
    sampratelfp = round(samprate/lfpdec);
    
    % Calculate filter coefficients
    [blfp, alfp] = butter(1, [lfplowfreq lfphighfreq]/(samprate*0.5));
    [b, a] = butter(1, [spikelowfreq spikehighfreq]/(samprate*0.5));
    
    % Determine timing for data
    sizewindow = ceil(window/2*samprate);
    spiketimeaxis = 1000*(0:1:(2*sizewindow-1))/samprate;
    
    seconds = data.stoptime-data.starttime-starttime;
    if seconds<0
        disp('Less than "starttime" of data in file - unable to analyze')
        continue
    end
    
    % Change totaltime to use limited amount of data if too large.
    totaltime = floor(samprate*seconds);
    % To Limit your data to a given number of seconds, uncomment below...
    %     totaltime = floor(samprate*60);
    %     if totaltime > floor(samprate*seconds)
    %          break
    %     end
    
    % Add RTCAR signal back into original
    if isfield(data, 'CARs')
        if CARundo == 1
            % minsize is used to make sure both CAR and STRM are same size
            minsize = min(length(data.CARs.data{1}), length(data.(spikedatafield).data{1}));
            % NOTE: THIS NEEDS TO BE FIXED! Resaving onto same structure
            % can temporarily multiply the size by number of channels using
            % this cellfun method.
            data.(spikedatafield).data = cellfun(@(x) x(1:minsize)+data.CARs.data{1}(1:minsize), data.(spikedatafield).data, 'UniformOutput', false);
            if CARadd == 1
                CARname = 'ppCAR';
            else
                CARname = 'noCAR';
            end
        elseif CARadd == 1
            disp('You cant add CAR twice');
            break;
        else
            CARname = 'rtCAR';
        end
    elseif CARadd == 1
        CARname = 'ppCAR';
    else
        CARname = 'noCAR';
    end
    
    % grabs and filters data
    datafilter = cell(1,numchan);
    datafilterlfp = cell(1,numchan);
    for x = 1:numel(data.(spikedatafield).data)
        datafilter{x} = filter(b,a,double(data.(spikedatafield).data{x}(:, starttime*samprate+1:totaltime))/intscale, [],2);
        % VERIFY DECIMATE is not overly affecting data - it incorporates an
        % 8th order lowpass before resampling.  NOTE: this is on top of the
        % bandpass done below using a butterworth filter.
        datafilterlfp{x} = decimate(filter(blfp,alfp,double(data.(spikedatafield).data{x}(:, starttime*samprate+1:totaltime))/intscale, [],2), lfpdec);
    end
    toc
    
    % calculates the rms of each of the 16 channels
    rmsnoise = cellfun(@(x) norm(x)/sqrt(numel(x)), datafilter);
    meanrmsnoise = mean(rmsnoise);
    
    % Looks for outliers in the RMS noise
    goodchannels = intersect(find(rmsnoise > .3*meanrmsnoise),find(rmsnoise < 2*meanrmsnoise));
    
    if CARadd == 1
        carsig = mean(cell2mat(datafilter(goodchannels)'));
        datafiltercar = cellfun(@(x) x-carsig, datafilter, 'UniformOutput', false);
        
        ppnoisecheck = cellfun(@(x) stdmult*std(x), datafiltercar);
        % Check for channels where pp noise is less than 1/3 of the mean
        noiseindex = find(ppnoisecheck <= mean(stdmult/3*ppnoisecheck));
        noiseindex = intersect(noiseindex,goodchannels);
        
        carsig = mean(cell2mat(datafilter(noiseindex)'));
        datafiltercar = cellfun(@(x) x-carsig, datafilter, 'UniformOutput', false);
        
        carlfp = mean(cell2mat(datafilterlfp(noiseindex)'));
        datafilterlfpcar = cellfun(@(x) x-carlfp, datafilterlfp, 'UniformOutput', false);
        
        rmsnoisecar = cellfun(@(x) norm(x)/sqrt(numel(x)), datafilter);
        meanrmsnoisecar = mean(rmsnoisecar);
        
        datafilter = datafiltercar;
        datafilterlfp = datafilterlfpcar;
        clear datafiltercar datafilterlfpcar
    end
    
    ppnoiseraw = cellfun(@(x) stdmult*std(x), datafilter);
    ppnoiselfp = cellfun(@(x) stdmult*std(x), datafilterlfp);
    
    % Runs through all 16 channels with a threshold, selecting 2400 us snapshot around maximum peak or valley (1200
    % before and 1200 after, based on TDT values)
    
    snip = cell(numchan,1);
    chanminholder = cell(numchan,1);
    sort.timestamp = cell(numchan,1);
    
    hh = waitbar(0,'Thesholding Channels...');
    holdermax = cellfun(@(x) find(x > (mean(x) + detthresh*std(x))), datafilter, 'UniformOutput', false);
    holdermin = cellfun(@(x) find(x < (mean(x) - detthresh*std(x))), datafilter, 'UniformOutput', false);
    
    for channel = 1:numchan
        
        % Test method for more efficiently finding spikes
%         [pksneg, locsneg] = findpeaks(-1*datafilter{channel}, 'minpeakdistance', 2*sizewindow, 'minpeakheight', detthresh*std((datafilter{channel})));
%         [pkspos, locspos] = findpeaks(datafilter{channel}, 'minpeakdistance', 2*sizewindow, 'minpeakheight', detthresh*std((datafilter{channel})));
        
        chantemp = [];
        chantempholder = [];
        
        placeholder = 0;
        
        %sample waveform is negative peak first
        % Go through all crossings
        for i = 1:numel(holdermin{channel})
            % Is it too early?
            if holdermin{channel}(i) <= (sizewindow)+1
                % And is it too close to the end?
            elseif holdermin{channel}(i) <= (numel(datafilter{channel}) - sizewindow)
                % Figure out minimum value and point at which it occurs in
                % snippet window
                [mintemp, mintempposition] = min(datafilter{channel}(holdermin{channel}(i)-sizewindow:holdermin{channel}(i)+sizewindow-1));
                % Adjust minimum position to be the index for the whole
                % array, not just the small snippet fed into it.
                mintempposition = holdermin{channel}(i) - sizewindow+1 + mintempposition;
                % If this minimum happens to be the holder value in all
                % minimums, then continue
                if (mintemp == datafilter{channel}(holdermin{channel}(i)));
                    placeholder = placeholder +1;
                    chantemp(placeholder, :) =  datafilter{channel}(mintempposition-sizewindow:mintempposition+sizewindow-1);
                    chantempholder(size(chantempholder,2)+1:size(chantempholder,2)+2*sizewindow+1) =  linspace(mintempposition-sizewindow,mintempposition+sizewindow-1,sizewindow*2+1);
                    sort.timestamp{channel}(placeholder) = mintempposition/samprate;
                end
            end
        end
        
        
        if positivespikes == 1
            % sample waveform is positive peak first
            for i = 1:length(holdermax{channel})
                if holdermax{channel}(i) <= (sizewindow)+1
                elseif holdermax{channel}(i) <= (numel(datafilter{channel}) - sizewindow)
                    [maxtemp, maxtempposition] = max(datafilter{channel}(holdermax{channel}(i)-sizewindow:holdermax{channel}(i)+sizewindow-1));
                    [mintemp, mintempposition] = min(datafilter{channel}(holdermax{channel}(i)-sizewindow:holdermax{channel}(i)+sizewindow-1));
                    maxtempposition = holdermax{channel}(i) - (sizewindow+1) + maxtempposition;
                    if (maxtemp == datafilter{channel}(holdermax{channel}(i))) && maxtemp>=abs(mintemp)
                        placeholder = placeholder +1;
                        chantemp(placeholder, :) =  datafilter{channel}(maxtempposition-(sizewindow):maxtempposition+(sizewindow-1));
                        chantempholder(size(chantempholder,2)+1:size(chantempholder,2)+2*sizewindow+1) =  linspace(maxtempposition-(sizewindow),maxtempposition+(sizewindow-1),sizewindow*2+1);
                        sort.timestamp{channel}(placeholder) = maxtempposition/samprate;
                    end
                end
            end
        end
        
        % Verify that candidates were found, if so, save in snip
        if size(chantemp,1)>0
            snip{channel}(1:placeholder, :) = chantemp;
            chanminholder{channel}(1:length(chantempholder)) = chantempholder;
        else
            % Setup conditions for set diff below for situations with no
            % spikes
            snip{channel}(1, 1:2*sizewindow+1) = zeros(1,2*sizewindow+1);
            chanminholder{channel}(1) = 0;
        end
        waitbar(channel/numchan)
    end
    clear chantemp
    close(hh);
    
    
    %--------------------------------------------------------------------------
    %                                   MCLUST
    %                                 Version 1.0
    %                               By : Kip Ludwig
    %                          Last Modified: 5-13-04
    %--------------------------------------------------------------------------
    
    % DESCRIPTION: See SnR description
    
    
    sort.snr = zeros(numchan,1);
    correlationmatrix = [];
    correlationmatrix2 = [];
    sort.meansig = zeros(numchan,1);
    ppnoise = zeros(numchan,1);
    sort.meanwaveforms = cell(numchan,1);
    sort.snip = cell(numchan,1);
    sort.sniptime = cell(numchan,1);
    U = cell(numchan,1);
    maxU = cell(numchan,1);
    fcmdata = cell(numchan,1);
    
    h(1) = figure(1);
    set(gcf, 'name', 'Pile-Plots');
    set(gcf, 'PaperOrientation', 'landscape', 'PaperPosition', rect);
    
    h(2) = figure(2);
    set(gcf, 'name', 'Clusters');
    set(gcf, 'PaperOrientation', 'landscape', 'PaperPosition', rect);
    
    squareplot = ceil(sqrt(numchan));
    
    hh = waitbar(0,'Clustering Channels...');
    %calculate waveforms and clusters for selected dataset
    for channel = 1:numchan
        %subtracts out signal and calculates the noise for each channel
        indextemp = 1:numel(datafilter{channel});
        % Determine if spikes were in holder
        nosignal1 = find(chanminholder{channel} > 0);
        % Grab non-zero indexes
        nosignal2 = chanminholder{channel}(nosignal1);
        % Compare indexes with spike data and grab non-spike indexes
        nosignal3 = setdiff(indextemp,nosignal2);
        % Grab all non-spike data
        nosignal4 = datafilter{channel}(nosignal3);
        % Calculate noise on the channel
        ppnoise(channel) =  stdmult*std(nosignal4);
        
        %holder checks to see there is a significant number of points above
        %on the given channel above threshold;  If there isn't enough points to
        %make reasonable clusters, the cluster is dropped from further analysis
        holder = find(sum(snip{channel},2));
        if length(holder) > 30
            
            %3 dimensional PCA
            [PC, SCORE, LATENT, TSQUARE] = princomp(squeeze(snip{channel}(1:holder(length(holder)),:)));
            X = [SCORE(:,1)' ; SCORE(:,2)'; SCORE(:,3)'];
            fcmdata{channel} = X';
            
            [center,U{channel},objFcn] = fcm(fcmdata{channel},2,[2, 100, 0, 0]); %#ok<ASGLU>
            objholder = min(objFcn);
            
            if maxunits<3
                maxunits=3;
            end
            
            for clusternumber = 3:maxunits
                [center,U{channel},objFcn] = fcm(fcmdata{channel},clusternumber,[2, 100, 0, 0]); %#ok<ASGLU>
                min(objFcn);
                if min(objFcn)/objholder > 0.5
                    sizemax = clusternumber - 1;
                    break
                else
                    sizemax = maxunits;
                    objholder = min(objFcn);
                end
            end
            
            %selects individual clusters via standard fuzzy means clustering
            [center,U{channel},objFcn] = fcm(fcmdata{channel},sizemax,[2, 100, 0, 0]);
            maxU{channel} = max(U{channel});
            
            for unit = 1 : sizemax
                figure(2)
                view(3)
                subplot(squareplot,squareplot,channel)
                title(channel);
                %Determine index of counted clusters
                index = find(U{channel}(unit, :) == maxU{channel} & U{channel}(unit,:) >= fcmthresh);
                %Determine index for not counted clusters
                index2 = find(U{channel}(unit, :) == maxU{channel} & U{channel}(unit,:) < fcmthresh);
                
                
                
                %             index = find(U{channel}(unit,:) >= .7);
                
                % Limits the number of points in a cluster to greater
                % than 30.  Less than 30 points in a cluster deemed to few for
                % further analysis (i.e. very low firing rate neuron or
                % abberation in signal)
                if length(index) > 30
                    
                    %plots the clusters in 3-d for each channel, color codes
                    %individual clusters
                    scatter3(fcmdata{channel}(index, 1), fcmdata{channel}(index, 2), fcmdata{channel}(index,3), plotColor(unit), plotMarker(unit));
                    hold on
                    if allclusters == 1
                        scatter3(fcmdata{channel}(index2, 1), fcmdata{channel}(index2, 2), fcmdata{channel}(index2,3), plotColor(end), plotMarker(end));
                    end
                    plot3(center(unit,1),center(unit,2),center(unit,3),'color','k','marker',plotMarker(unit),'markersize',15,'LineWidth',2)
                    drawnow
                    axis tight
                    
                    
                    sort.snip{channel, unit} = squeeze(snip{channel}(index,:));
                    sort.sniptime{channel,unit} = sort.timestamp{channel}(index);
                    sort.meanwaveforms{channel}(unit,:) = mean(sort.snip{channel,unit});
                    
                    sort.snr(channel,unit) = (max(mean(squeeze(snip{channel}(index,:)))-min(mean(squeeze(snip{channel}(index,:))))))...
                        /(ppnoise(channel));
                    
                    sort.meansig(channel,unit) = max(mean(squeeze(snip{channel}(index,:))))-min(mean(squeeze(snip{channel}(index,:))));
                    
                    % PILE PLOTS
                    if sort.snr(channel,unit) > snrthresh;
                        figure(1)
                        subplot(squareplot,squareplot,channel)
                        title({['Channel ' num2str(channel)]})
                        ylabel('Amplitude [\muV]')
                        xlabel('Time [ms]')
                        hold on
                        plot(spiketimeaxis, 1e6*snip{channel}(index,:),plotColor(unit))
                        %                             axis([0 2*sizewindow+1 min(min(squeeze(snip{channel}(index,:)))) max(max(squeeze(snip{channel}(index,:)))) ])
                        legend(num2str(sort.snr(channel,sort.snr(channel,:)>snrthresh),3), 'Location', 'SE')
                    end
                    axis tight;
                end
            end
        end
        waitbar(channel/numchan)
    end
    close(hh)
    
    % Make the Mean Template Plot, Nick Style
    h(3) = figure(3);
    set(gcf, 'name', 'Mean-Waveforms');
    set(gcf, 'PaperOrientation', 'landscape', 'PaperPosition', rect);
    
    sort.numberofunitsperchannel = sum(sort.snr>snrthresh,2);
    sort.numchanswithunits = sum(sort.numberofunitsperchannel>0);
    sort.spikerate = cellfun(@(x) numel(x)/seconds, sort.sniptime);
    
    squareplot2 = ceil(sqrt(sort.numchanswithunits));
    xx=1;
    leg = cell(0);
    
    for x = find(sort.numberofunitsperchannel)'
        for y = 1:size(sort.meanwaveforms{x},1)
            if sort.snr(x,y)>snrthresh
                figure(3);
                subplot(squareplot2,squareplot2,xx)
                hold on;
                plot(spiketimeaxis, 1e6*squeeze(sort.meanwaveforms{x}(y,:)), plotColor(y))
                leg{end+1} = [num2str(sort.snr(x,y),3) '-SNR (' num2str(1e6*sort.meansig(x,y),3) '-V_p_p)'];
            end
        end
        axis tight
        title(['Channel ' num2str(x)])
        xlabel('Time [ms]')
        ylabel('Amplitude [\muV]')
        legend(leg, 'Location', 'SE')
        leg = cell(0);
        xx = xx + 1;
    end

    h(4) = figure(4);
    set(gcf, 'name', 'Raw-Spike');
    set(gcf, 'PaperOrientation', 'landscape', 'PaperPosition', rect);
    h(5) = figure(5);
    set(gcf, 'name', 'Raw-LFP');
    set(gcf, 'PaperOrientation', 'landscape', 'PaperPosition', rect);
    
    xx = 1;
    for channel = 1:numchan
        
        clear holderzeros
        
        holderzeros = zeros(numel(datafilter{channel}),1);
        holderzeros(find(chanminholder{channel} ~= 0)) = 1;
        
        for i = 1 : samprate*2: length(datafilter{channel})-2*samprate+1
            holderzerosum(i) = sum(holderzeros(i:i+2*samprate-1));
        end
        
        [~, number] = max(holderzerosum);
        
        maxposition = (number-1)*(2*samprate) +1;
        
        if maxposition == 1
            maxpositon = 60;
        end
        
        figure(4)
        subplot(squareplot,squareplot,xx)
        plot(1e6*datafilter{channel}((maxposition:maxposition+2*samprate-1)));
        %     axis([1 2*samprate 1.2*min(datafilter(channel,(maxposition:maxposition+2*samprate-1)))...
        %         1.2*abs(min(datafilter(channel,(maxposition:maxposition+2*samprate-1))))]);
        
        title({['Channel ', num2str(channel)]; ['SNR ',num2str(max(sort.snr(channel,:)),3)]; ['Pk-Pk Noise ', num2str(1000000*ppnoise(channel),3)]});
        ylim([-150 150])
        
        figure(5)
        subplot(squareplot,squareplot,xx)
        maxpositionlfp = ceil(maxposition/lfpdec);
        plot(datafilterlfp{channel}(maxpositionlfp:maxpositionlfp+2*sampratelfp-1),'r');
        
        title({['Channel ', num2str(channel)]; ['Pk-Pk Noise ', num2str(1e6*ppnoiselfp(channel),3)]});
        
        xx = xx + 1;
    end
    
    % Make autocorrelograms
    h(6) = figure(6);
    set(gcf, 'name', 'Autocorrelograms');
    set(gcf, 'PaperOrientation', 'landscape', 'PaperPosition', rect);
    edges = -0.1:0.01:0.1;
    numauto = 25;
    autocor = cell(numchan,1);
    lags = cell(numchan,1);
    temphist = cell(1,1);
    for channel = 1:numchan
        [mval, mloc] = max(sort.snr(channel, :));
        if mval>snrthresh
            temphist{channel} = hist(sort.sniptime{channel, mloc},round(seconds*1000));
            [autocor{channel}, lags{channel}] = xcorr(temphist{channel}, numauto);
            %Reset center peak to zero as it hits itself everytime.
            autocor{channel}(lags{channel}==0)=0;
            subplot(squareplot,squareplot,channel)
            bar(lags{channel}, round(autocor{channel}))
            axis tight
            xlabel('time(ms)')
            ylabel('Spike Count')
            title({['Channel ' num2str(channel)]; num2str(mval)})
        end
    end
    
    % Make Spectograms of LFP Data
    h(7) = figure(7);
    set(gcf, 'name', 'LFP-Spectrogram');
    set(gcf, 'PaperOrientation', 'landscape', 'PaperPosition', rect);
    
    for channel = 1:numchan
        %         [lfpspec.S{channel},lfpspec.F{channel},lfpspec.T{channel}, lfpspec.P{channel}] = spectrogram(datafilterlfp{channel},round(seconds), [], 2048, sampratelfp);
        subplot(squareplot,squareplot,channel)
        spectrogram(decimate(datafilterlfp{channel}, 10),round(sampratelfp/10), round(sampratelfp/10*.75), 256, sampratelfp/10, 'yaxis');
        %         surf(lfpspec.T{channel},lfpspec.F{channel},10*log10(lfpspec.P{channel}),'edgecolor','none'); axis tight;
        view(0,90);
        xlabel('Seconds'); ylabel('Hz');
    end
    
    

        hh = warndlg('Saving Figures, Please Wait');
        
        % Change to Analysis directory to save files in.
        cd(file.savepath)
        
        % Changed from tank name to allow for multiple copies....
        figsave = [file.fname{multifile}(1:end-4) '_'];
        
        for index = 1:numel(h)
            if savefig == 1
                hgsave(h(index), [figsave get(h(index), 'name') '_' CARname], '-v7.3')
            end
            if savetif == 1
                print(h(index), '-dtiff', '-r300', [figsave get(h(index), 'name') '_' CARname])
            end
            if saveeps == 1
                print(h(index), '-depsc2', '-tiff', '-r300', [figsave get(h(index), 'name') '_' CARname])
            end
        end
        
        close(hh);
        
        % Choose variables to save to MAT file to reopen later
        save([figsave '_Sorts_' CARname], 'sort', 'ppnoise*', '-v7.3')
    toc
end

% Close worker pool if still has workers
if matlabpool('size')
    matlabpool close
end