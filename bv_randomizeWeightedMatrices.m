function Wrandomized = bv_randomizeWeightedMatrices(Ws, m)
% 
% 
counter = 0;
n = size(Ws,3);
Wrandomized = zeros([size(Ws,1) size(Ws,2) n m]);
rng(100000)
for iW = 1:n
    currW = Ws(:,:,iW);

    weights = squareform(currW);
    I = find(weights > 0);
    
    lng = printPercDone(n*m, counter);
    for j = 1:m
        weights(I) = weights(I(randperm(numel(I))));
        Wrandomized(:,:,iW,j) = squareform(weights);
        
        counter = counter + 1;
    end  
    fprintf(repmat('\b', 1, lng))
end

fprintf('\n')