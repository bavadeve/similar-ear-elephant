function varargout = bv_randomizeMetric (randWs, varargin)

if ~iscell(metrics)
    metrics = {metrics};
end

k = size(randWs,4);
n = length(metric);

for j = 1:n
    currMetric = metrics{n};
    for i = 1:k
        currRandW = randWs(:,:,:,i);
        
        switch currMetric
            
            case 'CPL'
                output{j}(:,i) = calculatePathlengthWs(randWs, 'weighted');
                
                
            case 'CC'
                output{j}(:,i) = calculatePathlengthWs(randWs, 'weighted');

        end
    end
    
    varargout{j} = mean(output{j},2);
end

