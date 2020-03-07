function [SWPs, delta_Cs, delta_Ls] = gr_calculateSmallworldPropensityWs(Ws)
% Function to calculate small-worldness index on multiple adjecency
% matrices.
%
%  usage:
%   [SWPs, delta_Cs, delta_Ls] = gr_calculateSmallworldPropensityWs(Ws)
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

n = size(Ws, 1);
m = size(Ws, 3);

SWPs = zeros(m, 1);
delta_Cs = zeros(m, 1);
delta_Ls = zeros(m, 1);

counter = 0;
fprintf('\tCalculating small-world-propensity ... ')
for i = 1:m
    lng = printPercDone(m, counter);
    currW = Ws(:,:,i);
    if all(all(isnan(currW)))
        SWPs(i) = NaN;
        delta_Cs(i) = NaN;
        delta_Ls(i) = NaN;
        fprintf(repmat('\b', 1, lng))
        counter = counter + 1;
        continue
    end
        currWnrm = gr_normalizeW(currW);
    try
        [SWPs(i),delta_Cs(i),delta_Ls(i)] = small_world_propensity(currWnrm, 'O');
    catch
        SWPs(i) = NaN;
        delta_Cs(i) = NaN;
        delta_Ls(i) = NaN;
    end
    fprintf(repmat('\b', 1, lng))
    counter = counter + 1;
end
fprintf('done! \n')

