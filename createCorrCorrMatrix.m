function [R, P] = createCorrCorrMatrix(Ws)

R = zeros(size(Ws,3), size(Ws,3));
P = R;
for i = 1:size(Ws,3)
    currW1 = Ws(:, :, i);
        
    for j = 1:size(Ws,3)
        currW2 = Ws(:, :, j);
        
        [currR, currP] = correlateMatrices(currW1, currW2);
        R(i,j) = currR;
        P(i,j) = currP;
    end
end
