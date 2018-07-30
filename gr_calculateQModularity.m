function [Ci, Q] = gr_calculateQModularity(Ws, edgeType)

n = size(Ws,1);
m = size(Ws, 3);
% L = zeros(1, size(Ws,3));
for i = 1:m
    W = Ws(:,:,i);
    % find removed channels
    rmChannels = sum(isnan(W)) == (size(W,2) - 1);
    if ~sum(rmChannels)==0
        
        Ci(:,i) = nan(1,n);
        Q(i) = NaN;
        continue
        
    end
    
    switch edgeType
        case 'binary'
            [Ci(:,i),Q(i)] = modularity_und(W);
        case 'weighted'
            W = threshold_proportional(W, 0.15);
            [Ci(:,i),Q(i)] = modularity_und(W);
    end
end
