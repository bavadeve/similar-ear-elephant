function Wrandomized = bv_randomizeWeightedMatrices(Ws, m)
% 
% 
counter = 0;
n = size(Ws,3);
Wrandomized = zeros([size(Ws,1) size(Ws,2) n m]);
rng(100000)
for iS = 1:n
    currW = Ws(:,:,iS);
    for iW = 1:m
        
        
        weights = squareform(currW);
        I = find(weights > 0);
        
        for j = 1:5
            weights(I) = weights(I(randperm(numel(I))));
            I = find(weights > 0);
            counter = counter + 1;
        end
        Wrandomized(:,:,iS,iW) = squareform(weights);
    end
end