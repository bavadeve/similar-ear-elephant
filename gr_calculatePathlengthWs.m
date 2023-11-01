function [L, eff, rad] = gr_calculatePathlengthWs(As, edgeType)
% Function to calculate characteristic path length on multiple adjecency
% matrices. 
%
% usage:
%   [CPLs] = gr_calculatePathlengthAs(As, edgeType)
%
% With As being the adjencency matrices with dim(chan * chan * subject)
% and edgeType options 'weighted', 'binary' and 'mst' (for minimum spanning
% tree graphs)

sz = size(As);
N = sz(1);
ndims = length(sz);

if ndims > 3
    extraDims = sz(3:end);
    nAsz = [sz(1) sz(2) prod(sz(3:end))];
    As = reshape(As, nAsz);
end

n = size(As, 1);
m = size(As, 3);

L = zeros(1, size(As,3));
updateWaitbar = waitbarParfor(m, 'calculating path lengths');
parfor i = 1:m
    A = As(:,:,i);
    % find removed channels
    rmChannels = sum(isnan(A)) == 31;
    if ~isempty(find(rmChannels))
        
        A(rmChannels,:) = [];
        A(:,rmChannels) = [];
        
    end
    
    switch edgeType
        case 'binary'
            D = distance_bin( A );
            [L(i), eff(i), ~, rad(i)] = charpath( D );
            
        case 'weighted'
            D = distance_wei_floyd(A, 'inv');
            L(i) = mean( squareform(D) );
            
        case 'mst'
            D = distance_wei( A );
            [L(i), eff(i), ~, rad(i)] = charpath( D );
            
        otherwise
            error('unknown adjacency matrix type')
            
    end
    updateWaitbar();
end

if ndims > 3
    L = reshape(L, extraDims);
    switch edgeType
        case {'binary', 'mst'}
            L = reshape(L, [extraDims]);
            eff = reshape(eff, [extraDims]);
            rad = reshape(rad, [extraDims]);
    end        
end
