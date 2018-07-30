function varargout = gr_calculateMetrics(Ws, edgeType, graphMetric)

n = size(Ws,4);
m = size(Ws,5);

varargout = cell(1,length(graphMetric));
for iGrph = 1:length(graphMetric)
    grMetric = graphMetric{iGrph};
    
    fprintf('\t Calculating %s ... ', grMetric)
    
    counter = 0;
    for i = 1:n
        for j = 1:m
            counter = counter + 1;
            currWs = Ws(:,:,:,i,j);
            
            switch grMetric
                case 'CC'
                    lng = printPercDone(n*m, counter);
                    varargout{iGrph}(:,i,j) = calculateClusteringWs(currWs, edgeType);
                    fprintf(repmat('\b', 1, lng))

                    
                case 'CPL'
                    lng = printPercDone(n*m, counter);
                    varargout{iGrph}(:,i,j) = calculatePathlengthWs(currWs, edgeType);
                    fprintf(repmat('\b', 1, lng))
                    
                case 'S'
%                     lng = printPercDone(n*m, i);
                    
                    [varargout{iGrph}(:,i,j), CWnrm(:,i,j), CPLnrm(:,i,j)] = ...
                        gr_calculateSmallworldnessWs(currWs, edgeType);            
%                     fprintf(repmat('\b', 1, lng))
                case 'Q'
                    lng = printPercDone(n*m, counter);
                    [varargout{iGrph}(:,i,j) varargout{iGrph+1}(:,i,j)] = gr_calculateQModularity(currWs, edgeType);
                    fprintf(repmat('\b', 1, lng))
            end
        end
    end
    fprintf('done! \n')
end

if sum(ismember(graphMetric, 'S'))
    varargout{end+1} = CWnrm;
    varargout{end+1} = CPLnrm;
end


