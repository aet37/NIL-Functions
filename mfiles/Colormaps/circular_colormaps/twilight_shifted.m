function [map] = twilight_shifted(N)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if ~exist('N','var') || isempty(N)
    N=256;
end
map = flipud(circshift(twilight(N),fix(N/2),1));
end