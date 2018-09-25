function setAutoLimits(ax)

if nargin < 1
    try
        h = gca; %current figure handle
    catch
        error('current figure not found, please give handle h as input')
    end
end

dataObjs = get(ax, 'Children'); %handles to low-level graphics objects in axes

data = dataObjs.CData;
minlim = min(squareform(data));
maxlim = max(squareform(data));

set(ax, 'CLim', [minlim maxlim]);
