function vislabels(L,txtcolor,txtsz,figno)
%VISLABELS Visualize labels of connected components
%   VISLABELS is used to visualize the output of BWLABEL.
%
%   VISLABELS(L), where L is a label matrix returned by BWLABEL,
%   displays each object's label number on top of the object itself.
%
%   VISLABELS(L, COLOR, FIGNO), where COLOR is the text color string or RGB,
%   and FIGNO is the figure number to add the labels to.
%
%   Note: VISLABELS requires the Image Processing Toolbox.
%
%   Example
%   -------
%       bw = imread('text.png');
%       L = bwlabel(bw);
%       vislabels(L)
%       axis([1 70 1 70])
%
%       im_overlay4(avgim(:,:,1),maskL)
%       myVisLabels(maskL)

%   Steven L. Eddins
%   Copyright 2008 The MathWorks, Inc.

% Form a grayscale image such that both the background and the
% object pixels are light shades of gray.  This is done so that the
% black text will be visible against both background and foreground
% pixels.

if ~exist('txtsz','var'), txtsz=[]; end;
if ~exist('txtcolor','var'), txtcolor=[]; end;
if ~exist('figno','var'), figno=[]; end;

do_currentfig=0;

if isempty(txtsz), txtsz=10; end;
if isempty(txtcolor), txtcolor=[1 1 0]; end;
if isempty(figno), do_currentfig=1; figno=gcf; end;

% Display the image, fitting it to the size of the figure.
if do_currentfig,
  imageHandle = gcf;
  axesHandle = gca;
else,
  background_shade = 200;
  foreground_shade = 240; 
  I = zeros(size(L), 'uint8');
  I(L == 0) = background_shade;
  I(L ~= 0) = foreground_shade;
  imageHandle = imshow(I, 'InitialMagnification', 'fit');  
  axesHandle = ancestor(imageHandle, 'axes');
end;

% Get the axes handle containing the image.  Use this handle in the
% remaining code instead of relying on gca.

% Get the extrema points for each labeled object.
s = regionprops(L, 'Extrema');

% Superimpose the text label at the left-most top extremum location
% for each object.  Turn clipping on so that the text doesn't
% display past the edge of the image when zooming.
hold(axesHandle, 'on');
for k = 1:numel(s)
   e = s(k).Extrema;
   text(max(e(:,1)), min(e(:,2)), sprintf('%d', k), ...
      'Parent', axesHandle, ...
      'Clipping', 'on', ...
      'Color', txtcolor, ...
      'FontSize', txtsz, ...
      'FontWeight', 'bold');
end
hold(axesHandle, 'off');

