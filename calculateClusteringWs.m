function [C] = calculateClusteringWs(Ws, edgeType)

m = size(Ws, 3);
C = zeros(1, m);
for i = 1:m
    W = Ws(:,:,i);
    
    % find removed channels
    rmChannels = (nansum(W)==0);
    if ~isempty(rmChannels)
        
        W(rmChannels,:) = [];
        W(:,rmChannels) = [];
        
    end
    
    W(isnan(W)) = 0;
    
    if isempty(W)
        C(i) = NaN;
        continue
    end
    
    switch edgeType
        case 'binary'
            C(i) = mean(clustering_coef_bu(W));
        case 'weighted'
            Wnrm = weight_conversion(W, 'normalize');
%             Wnrm = Wnrm .* double(Wnrm >0);
            C(i) = mean(clustering_coef_wu(Wnrm));
        case 'mst'
            Wnrm = double(W>0)
            C(i) = mean(clustering_coef_bu(Wnrm));
    end
end