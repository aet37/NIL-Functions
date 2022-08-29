function [dxy,res,c]=urapiv3(a,b,s2nm,s2nl)
% Usage ... [dxy,res]=urapiv3(a,b,s2nm,s2nl)
%
% Same as urapiv2 except performed on entire image as opposed to sub-regions
% within an image. Defaults: s2nm=2, s2nl=10.

if nargin<4,
  s2nl=10;
end;
if nargin<3,
  s2nm=2;
end;

c = cross_correlate(a,b,2*max(size(a)));

[peak1,peak2,pixi,pixj] = find_displacement(c,s2nm);
if length(pixi)>1,
  disp(sprintf('  flat peaks detected (%d)...',length(pixi)));
  pixi=pixi(1); pixj=pixj(1);
end;

[peakx,peaky,s2n] = sub_pixel_velocity(c,pixi,pixj,peak1,peak2,s2nl,size(a));

% Scale the pixel displacement to the velocity
u = (size(a,2)-peaky);
v = (size(a,1)-peakx);

dxy = u + i*v;
res = [u v s2n s2nm s2nl peakx peaky pixi pixj peak1 peak2];

if (nargout==0)
  show(c)
  xlabel(sprintf('%f %f',u,v))
  [u v],
  [s2n],
  [s2nm s2nl],
  [peakx peaky pixi pixj]
  [peak1 peak2]
end
end


%
% External functions
%

function [c] = cross_correlate(a2,b2,Nfft)

if (nargin<3),
  Nfft=max([size(a2) size(b2)]);
end;

c = zeros(Nfft,Nfft);

% Remove Mean Intensity from each image
a2 = a2 - mean2(a2);
b2 = b2 - mean2(b2);

% Rotate the second image ( = conjugate FFT)
b2 = b2(end:-1:1,end:-1:1);

% FFT of both
ffta=fft2(a2,Nfft,Nfft);
fftb=fft2(b2,Nfft,Nfft);

% Real part of an Inverse FFT of a conjugate multiplication
c = real(ifft2(ffta.*fftb));
end


function [peak1,peak2,pixi,pixj] = find_displacement(c,s2nm)

[Nfft,junk] = size(c);

peak1 = max(c(:));
[pixi,pixj]=find(c==peak1);

% Temporary matrix without the maximum peak
tmp = c;
tmp(pixi,pixj) = 0;

% If the peak is found on the border, we should not accept it
if (pixi==1) | (pixj==1) | (pixi==Nfft) | (pixj==Nfft)
  peak2 = peak1; 
  % we'll not accept this peak later, by means of SNR
else
  % look at SNR by: 1- peak detectability (1st-to-2nd ratio), 2- peak-to-mean ratio
  if (s2nm == 1) 
    % Remove 3x3 pixels neighbourhood around the peak
    tmp(pixi-1:pixi+1,pixj-1:pixj+1) = NaN;
    % Look for the second highest peak
    peak2 = max(tmp(:));
    [x2,y2] = find(tmp==peak2);
    tmp(x2,y2) = NaN;
    % Only if second peak is within the borders
    if (x2 > 1) & (y2 > 1) & (x2 < Nfft) & (y2 < Nfft)
      % look for the clear (global) peak, not for a local maximum
      while (peak2 < max(max(c(x2-1:x2+1,y2-1:y2+1))))
        peak2 = max(tmp(:));
        [x2,y2] = find(tmp==peak2);
        if x2 == 1 | y2==1 | x2 == Nfft | y2 == Nfft
          peak2 = peak1;      % will throw this one out later
          break;
        end
        tmp(x2,y2) = NaN;
      end
    else
      % second peak on the border means "second peak doesn't exist"
      peak2 = peak1;
    end
  elseif (s2nm == 2)
    peak2 = mean2(abs(tmp));
  end 
end 
end


function [peakx,peaky,s2n] = sub_pixel_velocity(c,pixi,pixj,peak1,peak2,s2nl,itt)

if max(c(:)) < 1e-3
  peakx = itt(2);
  peaky = itt(1);
  s2n = Inf;
  return
end

if ~peak2
  s2n = Inf;          % Just to protect from zero dividing.
else
  s2n = peak1/peak2;
end

% if SNR is lower than the limit, "mark" it
if (s2n < s2nl)
  peakx = itt(2);
  peaky = itt(1);
else
  % otherwise, calculate sub-pixel displacement by means of gaussian bell
  f0 = log(c(pixi,pixj));
  f1 = log(c(pixi-1,pixj));
  f2 = log(c(pixi+1,pixj));
  peakx = pixi+ (f1-f2)/(2*f1-4*f0+2*f2);
  f0 = log(c(pixi,pixj));
  f1 = log(c(pixi,pixj-1));
  f2 = log(c(pixi,pixj+1));
  peaky = pixj+ (f1-f2)/(2*f1-4*f0+2*f2);

  if (~isreal(peakx)) | (~isreal(peaky))
    peakx = itt(2);
    peaky = itt(1);
  end
end
end


