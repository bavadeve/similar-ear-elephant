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
            [Ci(:,i),Q(i)] = community_louvain(W);
        case 'weighted'
            Wnrm = gr_normalizeW(W);
            [Ci(:,i),Q(i)] = community_louvain(Wnrm);
    end
end