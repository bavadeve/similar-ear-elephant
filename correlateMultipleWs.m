function [R, P] = correlateMultipleWs(Ws1, Ws2)

if nargin < 2
    error('Please add in two sets of correlations matrices')
end

if sum(size(Ws1) == size(Ws2)) ~= length(size(Ws1))
    error('size Ws1 (%s) does not equal size Ws2 (%s)', num2str(size(Ws1)), num2str(size(Ws2)))
end

for iW = 1:size(Ws1,3);
    currW1 = Ws1(:,:,iW);
    currW2 = Ws2(:,:,iW);
    
    [currR, currP] = correlateMatrices(currW1, currW2);
    R(iW) = currR;
    P(iW) = currP;
end

