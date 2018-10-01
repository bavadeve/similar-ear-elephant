function setAutoLimits(ax)
% finds the correct limits for a connectivity matrix based on the highest and
% lowest values in the matrix (so ignores the diagonal)
%
% usage:
%   setAutoLimits(ax)

if nargin < 1
    try
        ax = gca; %current figure handle
    catch
        error('current figure not found, please give handle ax as input')
    end
end

dataObjs = get(ax, 'Children'); %handles to low-level graphics objects in axes

data = dataObjs.CData;
minlim = min(nansquareform(data));
maxlim = max(nansquareform(data));

set(ax, 'CLim', [minlim maxlim]);
