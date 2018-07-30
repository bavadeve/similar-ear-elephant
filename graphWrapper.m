clear all

str = 'pli';

a = dir([str '*_*'  '.mat']);
resultStr = {a.name};

% resultStr = {
inputData = 'weighted';

graphMetrics = {'CPL','CC'};

for i = 1:length(resultStr)
    disp(resultStr{i})
    fprintf('\t loading ... ')
    load(resultStr{i})
    fprintf('done! \n')
    
    switch inputData
        case 'weighted'
            %             range = [0.001 1];
            
            %             a = (range(2)-range(1))/(max(Ws(:))-min(Ws(:)));
            %             b = range(2) - a * max(Ws(:));
            %             Wsnrm = a * Ws + b;
            %
            
            for iMetrics = 1:length(graphMetrics)
                switch graphMetrics{iMetrics}
                    case 'CC'
                        CC = gr_calculateMetrics(Ws, 'weighted', {'CC'});
                        graphResults.(inputData).CC = CC;
                    case 'CPL'
                        CPL = gr_calculateMetrics(Ws, 'weighted', {'CPL'});
                        graphResults.(inputData).CPL = CPL;
                    case 'S'
                        [S, CCnrm, CPLnrm] = gr_calculateMetrics(Ws, 'weighted', {'S'});
                        graphResults.(inputData).S = S;
                        graphResults.(inputData).CCnrm = CCnrm;
                        graphResults.(inputData).CPLnrm = CPLnrm;
                    case 'Q'
                        [Ci, Q] = gr_calculateMetrics(Ws, 'weighted', {'Q'});
                        graphResults.(inputData).Q = Q;
                        graphResults.(inputData).Ci = Ci;
                    case 'degree'
                        graphResults.(inputData).degree = squeeze(nanmean(Ws));
                end
            end
            
            
            fprintf('\t saving to %s ... ', resultStr{i})
            save(resultStr{i}, 'graphResults', '-append')
            fprintf('done! \n')
            
            
        case 'binary'
            nans = isnan(Ws);
            Bs = double(Ws>0.15);
            Bs(nans) = NaN;
            [graph.(inputData).CC, graph.(inputData).CPL] = ...
                gr_calculateMetrics(Bs, 'binary', {'CC', 'CPL'});
            
            fprintf('\t saving to %s ... ', resultStr{i})
            save(resultStr{i}, 'graph', '-append')
            fprintf('done! \n')
            
        case 'binaryRandom'
            [graph.(inputData).CC, graph.(inputData).CPL] = ...
                gr_calculateMetrics(Brandom, 'binary', {'CC', 'CPL'});
            
            fprintf('\t saving to %s ... ', resultStr{i})
            save(resultStr{i}, 'graph', '-append')
            fprintf('done! \n')
            
        case 'weightedRandom'
            
            [graph.(inputData).CC, graph.(inputData).CPL] = ...
                gr_calculateMetrics(Wrandom, 'weighted', {'CC', 'CPL'});
            
            fprintf('\t saving to %s ... ', resultStr{i})
            save(resultStr{i}, 'graph', '-append')
            fprintf('done! \n')
    end
    
end

