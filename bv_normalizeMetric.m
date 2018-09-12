function output = bv_normalizeMetric(W, metric, nRands)

if nargin < 3
    nRands = 200;
end

randWs = squeeze(bv_randomizeWeightedMatrices(W, nRands));

switch metric
    
    case 'CC'
        C = calculateClusteringWs(W, 'weighted');
        Crand = calculateClusteringWs(randWs, 'weighted');
        output = mean(C./Crand);
        
    case 'CPL'
        CPL = calculatePathlengthWs(W, 'weighted');
        CPLrand = calculatePathlengthWs(randWs, 'weighted');
        output = mean(CPL./CPLrand);
        
    otherwise
        error('unknown metric')
end

