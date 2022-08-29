function [varargout] = urapiv(dirname,itt,spc,s2nm,s2nl,sclt,outl,crop_vector)
% URAPIV - Program reads all TIFF files in provided directory (in pairs),
% and calculates the velocity field, according to the following steps:
%
% 1. Read images in TIFF formats (original version reads in BMP)
% 2. Calcuate Cross-correlation for each itterogation block, according to
%    the grid spacing
% 3. Calculates Signal-To-Noise ratio and removes problematic results
% 4. Removes outlayers with the velocity values bigger than the average of the
%    matrix times Outlayer-limit, that is provided by the user
% 5. Removes local outlayers by means of adaptive local median filter
% 6. Fills in removed vectors by interpolation of the neighboor vectors
% 7. Presents all the results of position (x,y)  velocity (vx,vy) and S2N
%
% Usage:
%
% 				UraPIV(DIR,ITT,SPC,S2NM,S2NL,SCLT,OUTL)
%
% Inputs:
%
%        DIR - name of the directory with session images, (string)
%              like '/u/liberzon/roi/tifs', or shorter './tifs'
%        ITT - intterogation size in pixels, same on in X and Y directions (have to be 2^N)
%        SPC - spacing is the grid of the image in pixels
%        S2NM - Signal-To-Noise-Ratio calculation method:
%                1 - Peak-by-peak search with 3x3 pixels kernel
%                  or
%                2 - Peak-to-mean ratio in one interrogation area
%        S2NL - limit of signal-to-noise-ratio
%        SCLT - scaling*time in units [meter/pixel/seconds] (e.g., 1e5/26200)
%
%        OUTL - global filter, taking apart values that are bigger
%               that OUTL times the average value of the whole matrix.
%        CROPVEC - Vector of crop values in [left top right bottom] order,
%                  run URAPIV without this argument to enter it manually after
%                  seeing your images.
%
%
%   Usage:
%       vel = urapiv('./images',32,32,2,1,1,10,[0 0 0 0]);
%
% Authors: Alex Liberzon and Roi Gurka
% Co-Author: Uri Shavit
%
% Started at: 30-Jul-98
%
% Last modified at: 20-Jul-99. (on Alex's PC).

warning off
more off

% All arguments should be supplied, no defaults are defined:
if nargin < 7
    error('Usage: vel = urapiv(''./images'',32,32,2,1,1,10,[0 0 0 0]);');
end

% Argument check:
if s2nm ~=1 & s2nm ~= 2
    s2nm = 2;
end

[filenames,amount,ext] = ReadImDir(dirname); % [filenames,amount,filebase] = ReadImDir(dirname,'tif');
% image1 = fullfile(dirname,filenames{1});
% image2 = fullfile(dirname,filenames{2});
[a,b] = read_pair_of_images(fullfile(dirname,filenames{1}),fullfile(dirname,filenames{2}),[0 0 0 0],itt,spc,ext);

if isempty(a) | isempty(b)
    error('Something wrong with your images')
end

if ~exist('crop_vector','var')
    ah = figure;imshow(a),
    axis on,ax=axis; grid on; set(gca,'xtick',[0:itt:ax(2)],'xticklabel',[],...
        'ytick',[0:itt:ax(4)],'yticklabel',[]);
    bh = figure;imshow(b);
    axis on,ax=axis; grid on; set(gca,'xtick',[0:itt:ax(2)],'xticklabel',[],...
        'ytick',[0:itt:ax(4)],'yticklabel',[]);
    disp('')
    crop_vector = input(sprintf('%s \n %s \t ',...
        'Enter the number of interrogation lines to crop',...
        '[Left,Top,Right,Bottom], Enter for none '));
    if isempty(crop_vector),crop_vector = zeros(4,1); end

end

% matrix "veloci" includes the results of all the pairs of images
% veloci = zeros(;
% veloci = []; % too expensive in memory/speed
% learn pre-allocation:
% Prepare the results storage;
reslenx = (sx-itt)/spc+1;
resleny = (sy-itt)/spc+1;
res = zeros(reslenx*resleny,5);

veloci = zeros(reslenx*resleny*amount,5);
velociInd = 0;

for fileind = 1:2:2*amount-1	% main loop, for whole file list

    velociInd = velociInd + 1;

    image1 = fullfile(dirname,filenames{fileind}); % [dirname,filesep,filenames(fileind,:)];
    image2 = fullfile(dirname,filenames{fileind+1}); %[dirname,filesep,filenames(fileind+1,:)];

    [a,b] = read_pair_of_images(image1,image2,crop_vector,itt,spc,ext);
    [sx,sy]= size(a);


    resind = 0;

    a2 = zeros(itt);
    b2 = zeros(itt);
    Nfft = 2*itt;
    c = zeros(Nfft,Nfft);


    %%%%%% Start the loop for each interrogation block %%%%%%%

    for k=1:spc:sx-itt+1
        disp(sprintf('\n Working on %d pixels row',k))
        for m=1:spc:sy-itt+1

            % Remove following line if you like 'silent' run
            fprintf(1,'.');

            a2 = a(k:k+itt-1,m:m+itt-1);
            b2 = b(k:k+itt-1,m:m+itt-1);

            c = cross_correlate(a2,b2,Nfft);

            [peak1,peak2,pixi,pixj] = find_displacement(c,s2nm);

            [peakx,peaky,s2n] = sub_pixel_velocity(c,pixi,pixj,peak1,peak2,s2nl,sclt,itt);

            % Scale the pixel displacement to the velocity
            u = (itt-peaky)*sclt;
            v = (itt-peakx)*sclt;
            x = m+itt/2-1;
            y = k+itt/2-1;

            resind = resind + 1;
            res(resind,:) = [x y u v s2n];
        end
    end

    % NO_FILT_RES will be stored in '.._noflt.txt' file at the end of program
    no_filt_res = res;
    % Unfiltered, uninterpolated: (comment with % sign if you don't need it)
    fid = fopen([fullfile(dirname,filenames{fileind}(1:end-4)),'_noflt.txt'],'w');
    fprintf(fid,'%3d %3d %7.4f %7.4f %7.4f\n',no_filt_res');
    fclose(fid);

    % Reshape U and V matrices in two-dimensional grid and produce
    % velocity vector in U + i*V form (real and imaginary parts):

    u = reshape(res(:,3),resleny,reslenx);
    v = reshape(res(:,4), resleny,reslenx);
    vector = u + sqrt(-1)*v;

    % Remove outlayers - GLOBAL FILTERING
    vector(abs(vector)>mean(abs(vector(find(vector))))*outl) = 0;
    u = real(vector);
    v = imag(vector);

    % Adaptive Local Median filtering

    kernel = [-1 -1 -1; -1 8 -1; -1 -1 -1];
    tmpv = abs(conv2(v,kernel,'same'));
    tmpu = abs(conv2(u,kernel,'same'));

    % WE HAVE TO DECIDE WHICH LIMIT TO USE:
    % 1. Mean + 3*STD for each one separately OR
    % 2. For velocity vector length (and angle)
    % 3. OR OTHER.

    lmtv = mean(tmpv(find(tmpv))) + 3*std(tmpv(find(tmpv)));
    lmtu = mean(tmpu(find(tmpu))) + 3*std(tmpu(find(tmpu)));
    u_out = find(tmpu>lmtu);
    v_out = find(tmpv>lmtv);

    % Let's throw the outlayers out:
    u(u_out) = 0; u(v_out) = 0;
    v(v_out) = 0; v(u_out) = 0;
    vector = u + sqrt(-1)*v;

    res(:,3) = reshape(real(vector),resleny*reslenx,1);
    res(:,4) = reshape(imag(vector),resleny*reslenx,1);

    % Filtered results will be stored in '.._flt.txt' file
    filt_res = res;
    % Filtered, but not interpolated:
    fid = fopen([fullfile(dirname,filenames{fileind}(1:end-4)),'_flt.txt'],'w');
    fprintf(fid,'%3d %3d %7.4f %7.4f %7.4f\n',filt_res');
    fclose(fid);

    % Interpolation of the data:

    [indx,indy] = find(abs(vector)==0);

    while ~isempty(indx)

        for z=1:length(indx)
            k = [max(3,indx(z))-2:min(resleny-2,indx(z))+2];
            m = [max(3,indy(z))-2:min(reslenx-2,indy(z))+2];
            tmpvec = vector(k,m);
            tmpvec = tmpvec(find(tmpvec));
            vector(indx(z),indy(z)) = mean(real(tmpvec))+ sqrt(-1)*mean(imag(tmpvec));
        end
        [indx,indy] = find(abs(vector)==0);
    end
    res(:,3) = reshape(real(vector),resleny*reslenx,1);
    res(:,4) = reshape(imag(vector),resleny*reslenx,1);


    % Save results as ASCII (text) files:
    % Final (filtered, interpolated) results
    fid = fopen([fullfile(dirname,filenames{fileind}(1:end-4)),'.txt'],'w');
    fprintf(fid,'%3d %3d %7.4f %7.4f %7.4f\n',res');
    fclose(fid);

    % Results visualization
    % Only for final, filtered and interpolated data
    figure; imshow(a);
    hold on
    quiverm(res,'r');

    % Results for operating in other applications
    veloci(reslenx*resleny*(velociInd-1)+1:velociInd*reslenx*resleny,:) = res;

end % of the loop
if nargout == 1
    varargout{1} = veloci;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                    EXTERNAL FUNCTIONS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [A,B] = read_pair_of_images(image1,image2,crop_vector,itt,spc,ext)
        % READ_PAIR_OF_IMAGES - reads two images (image1,image2) as tif files
        % and crops them according to 'crop_vector'
        % Inputs:
        %         image1,image2 - tif file names (string)
        %         crop_vector - 4 x 1 vector of follwoing values:
        %         [left,top,right,bottom] - each value is a number of lines
        %                                   of interrogation areas (ITTxITT pixels)
        %                                   which should be removed before the analysis.
        %         itt - interrogation area size in pixels
        %         spc - grid spacing (overlapping) size in pixels
        %
        % Authors: Alex Liberzon & Roi Gurka
        % Date: 20-Jul-99
        % Last modified:
        % Copyright(c) 1999, Alex Liberzon

        A = imread(image1,ext);
        B = imread(image2,ext);
        A = double(A(:,:,1))/255;
        B = double(B(:,:,1))/255;

        %         A = rgb2gray(imread(image1,'tif'));
        %         B = rgb2gray(imread(image2,'tif'));
        [sx,sy]=size(A);[sxb,syb]=size(B);
        % A & B matrices HAVE to be of the same size, we take smallest:
        sx = min(sx,sxb); sy = min(sy,syb);

        % Crop the images to the desired size and
        % cut the last couple of pixels, so we'll get the
        % integer number of interrogation areas
        %
        %       ---- t ---
        %      |          |
        %      |          |
        %      l          r
        %      |          |
        %      |          |
        %       --- b ----
        %
        %
        l = crop_vector(1); % left side of the image
        t = crop_vector(2); % top side of the image
        r = crop_vector(3); % right side of the image
        b = crop_vector(4); % bottom of the image

        A = A(1+t*itt:spc*floor(sx/spc)-b*itt,1+l*itt:spc*floor(sy/spc)-r*itt);
        B = B(1+t*itt:spc*floor(sx/spc)-b*itt,1+l*itt:spc*floor(sy/spc)-r*itt);
        [sx,sy]=size(A);
    end


    function [c] = cross_correlate(a2,b2,Nfft)
        % CROSS_CORRELATE - calculates the cross-correlation
        % matrix of two interrogation areas: 'a2' and 'b2' using
        % IFFT(FFT.*Conj(FFT)) method.
        % Modified version of 'xcorrf.m' function from ftp.mathworks.com
        % site.
        % Authors: Alex Liberzon & Roi Gurka
        %

        c = zeros(Nfft,Nfft);
        % Remove Mean Intensity from each image
        a2 = a2 - mean2(a2);
        b2 = b2 - mean2(b2);
        % Rotate the second image ( = conjugate FFT)
        b2 = b2(end:-1:1,end:-1:1);
        % FFT of both:
        ffta=fft2(a2,Nfft,Nfft);
        fftb=fft2(b2,Nfft,Nfft);
        % Real part of an Inverse FFT of a conjugate multiplication:
        c = real(ifft2(ffta.*fftb));
    end

    function [peak1,peak2,pixi,pixj] = find_displacement(c,s2nm)
        % FIND_DISPLACEMENT - Finds the highest peak in cross-correlation
        % matrix and the second peak (or mean value) for signal-to-noise
        % ratio calculation.
        % Inputs:
        %         c - cross-correlation matrix
        %         s2nm - method (1 or 2) of S2N ratio calculation
        % Outputs:
        %         peak1 = highest peak
        %         peak2 = second highest peak (or mean value)
        %         pixi,pixj = row,column indeces of the peak1
        %
        % Authors: Alex Liberzon & Roi Gurka
        % Date: 20-Jul-99
        % Last modified:
        %

        % Find your majour peak = mean pixel displacement between
        % two interrogation areas:

        [Nfft,junk] = size(c);

        peak1 = max(c(:));
        [pixi,pixj]=find(c==peak1);

        % Temproraly matrix without the maximum peak:
        tmp = c;
        tmp(pixi,pixj) = 0;
        % If the peak is found on the border, we should not accept it:
        if pixi==1 | pixj==1 | pixi==Nfft | pixj==Nfft
            peak2 = peak1; % we'll not accept this peak later, by means of S2N
        else
            % Look for the Signal-To-Noise ratio by
            % 1. Peak detectability method: First-to-second peak ratio
            % 2. Peak-to-mean ratio - Signal-to-noise estimation

            if s2nm == 1		% First-to-second peak ratio
                % Remove 3x3 pixels neighbourhood around the peak
                tmp(pixi-1:pixi+1,pixj-1:pixj+1) = NaN;
                % Look for the second highest peak
                peak2 = max(tmp(:));
                [x2,y2] = find(tmp==peak2);
                tmp(x2,y2) = NaN;
                % Only if second peak is within the borders
                if x2 > 1 & y2 > 1 & x2 < Nfft & y2 < Nfft

                    % Look for the clear (global) peak, not for a local maximum:
                    while peak2 < max(max(c(x2-1:x2+1,y2-1:y2+1)))
                        peak2 = max(tmp(:));
                        [x2,y2] = find(tmp==peak2);
                        if x2 == 1 | y2==1 | x2 == Nfft | y2 == Nfft
                            peak2 = peak1;	% will throw this one out later
                            break;
                        end
                        tmp(x2,y2) = NaN;
                    end		% end of while
                else			% second peak on the border means "second peak doesn't exist"
                    peak2 = peak1;
                end    % if x2 >1 ......end
                % PEAK-TO-MEAN VALUE RATIO:
            elseif s2nm == 2
                peak2 = mean2(abs(tmp));
            end		% end of second peak search, both methods.
        end				% end of if highest peak on the border
    end



    function [peakx,peaky,s2n] = sub_pixel_velocity(c,pixi,pixj,peak1,peak2,s2nl,sclt,itt)
        % SUB_PIXEL_VELOCITY - Calculates Signal-To-Noise Ratio, fits Gaussian
        % bell, find sub-pixel displacement and scales it to the real velocity
        % according the the time interval and real-world-to-image-scale.
        %
        % Authors: Alex Liberzon & Roi Gurka
        % Date: Jul-20-99
        % Last Modified:

        % If peak2 equals to zero, it means that nothing was found,
        % and we'll divide by zero:

        % Alex, 29.10.2004, for empty windows
        if max(c(:)) < 1e-3
            peakx = itt;
            peaky = itt;
            s2n = Inf;
            return
        end

        if ~peak2
            s2n = Inf;		% Just to protect from zero dividing.
        else
            s2n = peak1/peak2;
        end

        % If Signal-To-Noise ratio is lower than the limit, "mark" it:
        if s2n < s2nl
            peakx = itt;
            peaky = itt;
        else            % otherwise, calculate the velocity

            % Sub-pixel displacement definition by means of
            % Gaussian bell.

            f0 = log(c(pixi,pixj));
            f1 = log(c(pixi-1,pixj));
            f2 = log(c(pixi+1,pixj));
            peakx = pixi+ (f1-f2)/(2*f1-4*f0+2*f2);
            f0 = log(c(pixi,pixj));
            f1 = log(c(pixi,pixj-1));
            f2 = log(c(pixi,pixj+1));
            peaky = pixj+ (f1-f2)/(2*f1-4*f0+2*f2);

            if ~isreal(peakx) | ~isreal(peaky)
                peakx = itt;
                peaky = itt;
            end

        end
    end


    function [filenames,amount,ext] = ReadImDir(directory,ext)

        % graphical extensions
        knownExtensions = {'bmp','jpg','tif','tiff','jpeg'};

        if nargin == 1 | isempty(ext)
            for i = 1:length(knownExtensions)
                direc = dir([directory,filesep,'*.',knownExtensions{i}]);
                if ~isempty(direc), ext = knownExtensions{i}; break, end
            end
        end

        direc = dir([directory,filesep,'*.',ext]); filenames={};
        [filenames{1:length(direc),1}] = deal(direc.name);
        filenames = sortrows(filenames);
        amount = length(filenames)/2; % amount of pairs
%         filebase = filename(1:regexpi(filename,'\d','once')-1);
        
%         if ~isempty(findstr(filenames{1},'_b')) % case 1 _b, _c
% %             amount = max(str2num(filenames{1,end-8:end-6}));
%             amount = str2num(filenames{1}(regexp(filenames{1},'\s*\d')));
%             filebase = filenames{1}(1:regexp(filenames{1},'_','once'));
%         else % sequential numbering, UTAH case
%             amount = length(direc)-1; % max(str2num(filenames(:,end-9:end-4)));
%             %             filebase = filenames(1,regexp(filenames(1,:),'\w\d*[.]')+1:regexp(filenames(1,:),'[.]')-1);
%             filebase = filenames(1,1:regexp(filenames(1,:),'\w\d*[.]'));
% 
%         end
    end

    function [] = quiverm(x,varargin)
        % QUIVERM - plots quiver plot of matrix,
        % assuming first column as X, second as Y
        % third as U, and forth as V.
        %
        % QUIVERM(A,'r') - plots quiver plot
        % of matrix A.
        % Used by QUIVERTXT function.
        %
        %
        %
        % Author: Alex Liberzon
        %

        if isstr(x)
            x = eval(x);
        end
        quiver(x(:,1),x(:,2),x(:,3),x(:,4),varargin{:});
    end
end