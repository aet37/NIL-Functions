function [] = vertlines(x_locs,format_str,linew,y_range,color,ax)
%VERTLINES plots vertical lines at the specified vector of x values
%   x: vector of x locations for lines
%   y_range (optional) max and min height of the lines, defaults to current
%       ylim of current axis
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
if ~exist('y_range','var') || isempty(y_range)
    y_range=get(ax,'ylim');
end

if ~exist('linew','var') || isempty(linew)
    linew=0.5;
end

% make t a row vector
if(size(x_locs,1))>1
    x_locs=x_locs';
end

% plot in current axis over existing plot
hold on
if exist('color','var')
    plot(repmat(x_locs,2,1),repmat(y_range',1,length(x_locs)),format_str,'linew',linew,'color',color)
else
    plot(repmat(x_locs,2,1),repmat(y_range',1,length(x_locs)),format_str,'linew',linew)
end