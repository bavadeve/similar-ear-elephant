function [ WsTrh ] = bv_thresholdMultipleWs(Ws, propThr)

for i = 1:size(Ws,3)
    currW = Ws(:,:,i);
    if sum(isnan(currW(:))) == numel(currW)
        WsTrh(:,:,i) = currW;
    end
    WsTrh(:,:,i) = threshold_proportional(currW, propThr);
end