function [] = horzlines(y_locs,format_str,linew,x_range,color,ax)
%HORZLINES plots horizontal lines at the specified vector of y values
%   y_locs: vector of y locations for lines
%   x_range (optional): max and min width of the lines, defaults to current
%       xlim of current axis
%   format_str (optional): matlab format string for line style, defaults to '-'
%   linew (optional): weight of lines, defaults to 0.5
%   color (optional): rgb triplet for line color. defaults to [0 0 0] black
%   ax (optional): axis to plot, defaults to current axis

% set default parameter values (current axis, solid black line, line width 0.5, full height of plot)
if ~exist('ax','var') || isempty(ax)
    ax=gca;
end
if (~exist('format_str','var') || isempty(format_str)) && (~exist('color','var') || isempty(color))
    format_str='k-';
elseif ~exist('format_str','var') || isempty(format_str)
    format_str='-';
end
if ~exist('x_range','var') || isempty(x_range)
    x_range=get(ax,'xlim');
end

if ~exist('linew','var') || isempty(linew)
    linew=0.5;
end

% make t a row vector
if(size(y_locs,1))>1
    y_locs=y_locs';
end

% plot in current axis over existing plot
hold on
if exist('color','var')
    plot(repmat(x_range',1,length(y_locs)),repmat(y_locs,2,1),format_str,'linew',linew,'color',color)
else
    plot(repmat(x_range',1,length(y_locs)),repmat(y_locs,2,1),format_str,'linew',linew)
end