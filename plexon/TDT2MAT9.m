%Pick a file, any file
clear all; close all; tic

% Start a pool of workers if one is not already running
% if ~matlabpool('size')
%     matlabpool open
% end

% Initialize ActiveX control for accessing Tank
TTX = actxcontrol('TTank.X');

% Connect to the local server (!!!Change Computer name to dynamic)
if TTX.ConnectServer('Local',getenv('computername'))
    disp('Connected to TTank Server')
else
    h = warndlg('Failed connecting to TTank');
    clear TTX
    close(1);
    return
end

% Pick your tank
% Get list of registered tanks
count = 0;
holder='temp';
while 1
    holder = TTX.GetEnumTank(count);
    if ~isempty(holder)
        specs.tankchoices{count+1} = holder;
    else
        break
    end
    count = count+1;
end

% See if any registered tanks and reorganize by name
if isfield(specs,'tankchoices')
    specs.tankchoices = unique(specs.tankchoices);
end

% Pick the desired registred tank to use or trigger browse
[tempselect,ok] = listdlg('PromptString','Select a Tank, or browse for one','ListString',specs.tankchoices, 'SelectionMode', 'single', 'CancelString', 'Browse');
if ok
    specs.tanks = cellstr(specs.tankchoices(tempselect));
    specs.pathname = char(specs.tanks);
    specs.alltanks{1} = specs.pathname;
else
    specs.pathname = uigetdir(pwd, 'Pick the directory containing your tanks, not an individual tank');
    cd(specs.pathname);
    d = dir(specs.pathname);
    specs.tankchoices = {d([d.isdir]).name};
    if numel(specs.tankchoices) == 2
        h = warndlg('No Tank Choices Available');
        TTX.ReleaseServer;
        clear TTX
        close(1);
        pause(5);
        close(h);
        return
    end
    % 3 to end to ignore . and .. from matlab dir.
    [tempselect,ok] = listdlg('PromptString','Select Tanks','ListString',specs.tankchoices(3:end));
    if ~ok
        h = warndlg('No valid tanks selected');
        TTX.ReleaseServer;
        clear TTX
        close(1);
        pause(5);
        close(h);
        return
    else
        % Add 2 to return and grab indexes.
        specs.alltanks = specs.tankchoices(tempselect+2);

%         specs.tank = specs.pathname(find(specs.pathname == '\', 1, 'last')+1:end);
    end
end

clear ok tempselect

% Determine number of tanks
specs.numtanks = numel(specs.alltanks);

% Select storage location for output files
specs.matpath = uigetdir(pwd, 'Pick the directory you want you MAT files in');
if ~specs.matpath
    h = warndlg('Invalid or no MAT storage path selected');
    TTX.ReleaseServer;
    clear TTX
    close(1);
    return
end

h = waitbar(0,'Converting Files...');

for tank=1:specs.numtanks
    
    % Open the desired tank
    if TTX.OpenTank([specs.pathname '\' specs.alltanks{tank}], 'R')
        disp([specs.alltanks{tank} ' Tank Opened'])
    else
        disp([specs.alltanks{tank} ' Tank Not Valid']);
        continue
    end
    
    if isfield(specs, 'blockchoices')
        specs = rmfield(specs, 'blockchoices');
    end
    
    % Retrieve all block names from tank
    count = 0;
    holder='temp';
    while 1
        holder = TTX.QueryBlockName(count);
        if ~isempty(holder)
            specs.blockchoices{count+1} = holder;
        else
            break
        end
        count = count+1;
    end
    
    clear count holder
    
    if isfield(specs,'blockchoices')
        specs.blockchoices = unique(specs.blockchoices);
    else
        disp('No valid blocks in that tank');
        TTX.CloseTank
        disp('Tank Closed')
        waitbar(tank/specs.numtanks);
        continue
    end
    
    % Pick the desired block to use
    if specs.numtanks == 1
        [tempselect,ok] = listdlg('PromptString','Select a Block','ListString',specs.blockchoices);
        if ok
            specs.blocks = cellstr(specs.blockchoices(tempselect));
        else
            h = warndlg('No Blocks selected');
            return
        end
    else
        % If you are doing multiple tanks, only option is all blocks
        specs.blocks = cellstr(specs.blockchoices);
    end
    specs.numblocks = numel(specs.blocks);
    clear ok tempselect   
    

    for curblock = 1:specs.numblocks
        data.tank = specs.alltanks{tank};
        % Create blockname for labelling mat file
        tempind = regexpi(specs.blocks{curblock}, '-');
        if ~isempty(tempind)
            data.block = [specs.blocks{curblock}(1:tempind) num2str(str2double(specs.blocks{curblock}(tempind+1:end)), '%03.0f')];
        else
            data.block = specs.blocks{curblock};
        end
        toc
        % Select the block from the server
        TTX.SelectBlock(specs.blocks{curblock});
        
        % Read in all available events in the current block
        data.eventcodes = TTX.GetEventCodes(0);
        data.events = arrayfun(@(x) TTX.CodeToString(x), data.eventcodes, 'UniformOutput', false);
        data.eventnames = regexprep(data.events, '\', 'Z');
        data.eventnames = regexprep(data.eventnames, '-', 'Z');
        
        % Function ReadEventsV(MaxRet As Long, TankCode As String, Channel
        % As Long, SortCode As Long, T1 As Double, T2 As Double, Options As String) As Long
        
        numevents = numel(data.events);
        for eventnum = 1:numevents
            % Determine number of channels in this event (Channel 0 positive
            % result means that it is an event marker or single channel data
            tempchans = TTX.ReadEventsV(1e2, data.events{eventnum}, 0, 0, 0, 0, 'ALL');
            chans = unique(TTX.ParseEvInfoV(0, tempchans, 4));
            if sum((chans < 0) | (~isfinite(chans)))
                for numchan = 1:256 %Max channels defined as 64 (Pentusa Max)
                    tempchans = TTX.ReadEventsV(1e1, data.events{eventnum}, numchan, 0, 0, 0, 'ALL');
                    if ~tempchans
                        numchan = numchan - 1; %#ok<FXSET,NASGU>
                        break
                    end
                end
                
                clear tempchans
                
            else
                numchan = numel(chans);
            end
            
            % Determine number of events / blocks and read in the data
            for chan = 1:numchan
                if numchan == 1
                    numrecords = TTX.ReadEventsV(1e5, data.events{eventnum}, 0, 0, 0, 0, 'ALL');
                else
                    numrecords = TTX.ReadEventsV(1e5, data.events{eventnum}, chan, 0, 0, 0, 'ALL');
                end
                tempb = TTX.ParseEvV(0,numrecords);
                data.(data.eventnames{eventnum}).data{chan} = reshape(tempb, 1, numel(tempb));
                if chan == 1
                    data.(data.eventnames{eventnum}).samprate = TTX.ParseEvInfoV(0, 0, 9);
                    data.(data.eventnames{eventnum}).time = TTX.ParseEvInfoV(0, numrecords, 6);
                    data.(data.eventnames{eventnum}).blocksize = length(data.(data.eventnames{eventnum})(chan).data)/length(data.(data.eventnames{eventnum})(chan).time);
                end
            end
        end
        
        data.starttime = TTX.CurBlockStartTime;
        data.starttimefancy = TTX.FancyTime(data.starttime ,'Y/O/D H:M:S');
        data.stoptime = TTX.CurBlockStopTime;
        data.stoptimefancy = TTX.FancyTime(data.stoptime ,'Y/O/D H:M:S');
        data = rmfield(data, 'events');
        
        specs.fnamemat = strcat(data.tank, '_', data.block);
        
        cd(specs.matpath);
        save(specs.fnamemat, 'data', '-v7.3')
        clear data
    end
    
    % Disconnect from the Tank and Release Server Control
    TTX.CloseTank
    disp('Tank Closed')
    waitbar(tank/specs.numtanks);
end

close(h);

% Disconnect from the Tank and Release Server Control
TTX.CloseTank
disp('Tank Closed')
TTX.ReleaseServer
disp('Server Released')

% Close worker pool if still has workers
if matlabpool('size')
    matlabpool close
end

% Close Figure windows
close(1)
toc
