function [L, eff, rad] = calculatePathlengthWs(Ws, edgeType)

n = size(Ws,1);
m = size(Ws, 3);

L = zeros(1, size(Ws,3));
for i = 1:m
    W = Ws(:,:,i);
    % find removed channels
    rmChannels = (nansum(W)==0);
    if ~isempty(find(rmChannels))
        
        W(rmChannels,:) = [];
        W(:,rmChannels) = [];
        
    end
    
    switch edgeType
        case 'binary'
            
            D = distance_bin( W );
            [L(i), eff(i), ~, rad(i)] = charpath( D );
            
        case 'weighted'
            
            W(W<0) = 0;
            %             W = W - min(squareform(W));
            %             W = mat2gray(W);
            %             W = weight_conversion(W, 'normalize');
            %             W(1:n+1:end) = 0;
            %             W(W>0) = 1./W(W>0);
            lengths = weight_conversion(W, 'lengths');
            D = distance_wei( lengths );
            [L(i), eff(i), ~, rad(i)] = charpath( D );
            
        case 'mst'
            
            D = distance_wei( W );
            [L(i), eff(i), ~, rad(i)] = charpath( D );
            
        otherwise
            error('unknown adjacency matrix type')
            
    end
end
