function [Ss, gamma, lambda] = gr_calculateSmallworldnessWs(Ws, edgeType, randWs, Cs, Ls)
% Function to calculate small-worldness index on multiple adjecency
% matrices. 
%
%  usage:
%   [Ss, gamma, lambda] = gr_calculateSmallworldnessWs(Ws, edgeType, randWs, Cs, Ls)
%
% with the following necessary inputs:
%  Ws:          adjacency matrix with dim(chan x chan x subject)
%  edgeType:    'weighted', 'binary', 'mst'
%
% and the following options inputs:
%  randWs:      randomized Ws based on input Ws with dim (chan x chan x subject x nrandomizations)
%  Cs:          earlier calculated clustering coefficients for all Ws 
%  CPL:         earlier calculated characteristic path lengths for all Ws 
%
% If options inputs are not given, they will be calculated in the function,
% which makes the function take longer.


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
    switch edgeType
        case 'weighted'
            evalc('randWs = gr_randomizeWeightedMatrices(Ws, 20);');
        case {'binary', 'mst'}
            evalc('randWs = bv_randomizeBinaryMatrices(Ws, 20);');
        otherwise
            error('unknown edgeType')
    end
end

if doCalcCs
    Cs = gr_calculateClusteringWs(Ws, edgeType);
end

if doCalcLs
    Ls = gr_calculatePathlengthWs(Ws, edgeType);
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
    randCs(:,i) = gr_calculateClusteringWs(currRandW, edgeType);
    randLs(:,i) = gr_calculatePathlengthWs(currRandW, edgeType);
    fprintf(repmat('\b', 1, lng))
end

gamma = Cs' ./ mean(randCs,2);
lambda = Ls' ./ mean(randLs,2);

Ss = gamma ./ lambda;

