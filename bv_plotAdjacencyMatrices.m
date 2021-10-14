function bv_plotAdjacencyMatrices(As, labels)

if nargin < 2
    labels = {};
end

[indx] = numSubplots(size(As,3));
figure;
for i = 1:size(As,3)
    subplot(indx(1),indx(2),i)
    imagesc(As(:,:,i))
    
    if ~isempty(labels)
        bv_autoCorrSettings(gca, labels)
    else
        bv_autoCorrSettings(gca)
    end
end