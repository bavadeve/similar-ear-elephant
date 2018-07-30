function [Ss, gamma, lambda] = gr_calculateSmallworldnessWs(Ws, edgeType, randWs, Cs, Ls)

doRandomize = 0;
if ~exist('randWs', 'var') 
        doRandomize = 1;
elseif isempty(randWs)
        doRandomize = 1;
end

doCalcCs = 0;
if ~exist('Cs', 'var')
    doCalcCs = 1;
elseif isempty(Cs)
    doCalcCs = 1;
end

doCalcLs = 0;
if ~exist('Ls', 'var')
    doCalcLs = 1;
elseif isempty(Ls)
    doCalcLs = 1;
end

if doRandomize 
    evalc('randWs = bv_randomizeWeightedMatrices(Ws, 100);');
end

if doCalcCs
    Cs = calculateClusteringWs(Ws, edgeType);
end

if doCalcLs
    Ls = calculatePathlengthWs(Ws, edgeType);
end

n = size(Ws,1);
m = size(Ws, 3);
k = size(randWs, 4);

Ss = zeros(1, size(Ws,3));

counter = 0;
for i = 1:k
    counter = counter + 1;
    lng = printPercDone(k, counter);
    currRandW = randWs(:,:,:,i);
    randCs(:,i) = calculateClusteringWs(currRandW, edgeType);
    randLs(:,i) = calculatePathlengthWs(currRandW, edgeType);
    fprintf(repmat('\b', 1, lng))
end

gamma = Cs' ./ mean(randCs,2);
lambda = Ls' ./ mean(randLs,2);

Ss = gamma ./ lambda;

