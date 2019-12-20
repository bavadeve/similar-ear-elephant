function Wrandomized = gr_randomizeWeightedMatrices(Ws, m)
% Creates a given amount of randomized weighted adjacency matrices based on
% input adjacency matrices
%
% usage:
%   [Wrandomized] = bv_randomizeWeightedMatrices(Ws, m)
%
% inputs
%  Ws:      adjacency matrices with dim(chan * chan * subject)
%  m:       amount of randomized networks per adjacency matrix

n = size(Ws,3);
Wrandomized = zeros([size(Ws,1) size(Ws,2) n m]);
rng(100000)
counter = 0;
for iS = 1:n
    currW = Ws(:,:,iS);
    lng = printPercDone(n, counter);

    for iM = 1:m
        weights = squareform(currW);
        I = find(weights > 0);
        for j = 1:10
            weights(I) = weights(I(randperm(numel(I))));
            I = find(weights > 0);
        end
        Wrandomized(:,:,iS,iM) = squareform(weights);

        
%         Wrandomized(:,:,iS,iM) = null_model_und_sign(currW, 5, 0.1);
        
        
    end
    counter = counter + 1;
    fprintf(repmat('\b', 1, lng))
end