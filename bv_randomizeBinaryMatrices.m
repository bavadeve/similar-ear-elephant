function randomWs = bv_randomizeBinaryMatrices(Ws, m)
% 
% 
randomWs = zeros([size(Ws) m]);
counter = 0;
n = size(Ws,3);
for iW = 1:n
    currW = Ws(:,:,iW);
    
    for j = 1:m 
        if isempty(nonzeros(currW))
            randomWs(:,:,iW,j) = zeros(size(currW));
        else
            randomWs(:,:,iW,j) = randomizer_bin_und(currW, 10);
        end
        counter = counter + 1;
    end  
    
    if counter ~= m;
        fprintf(repmat('\b',1,length(percStr)))
    end
    percDone = counter / (n * m) * 100;

    percStr = sprintf('%1.0f%%', percDone);
    fprintf([percStr '%']);
end

fprintf('\n')