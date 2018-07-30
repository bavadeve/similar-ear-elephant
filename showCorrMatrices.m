function showCorrMatrices(Ws)

figure;
subIndx1 = ceil(sqrt(size(Ws,3)));
subIndx2 = floor(sqrt(size(Ws,3)));
for iW = 1:size(Ws,3)
    subplot(subIndx2, subIndx1, iW)
    imagesc(Ws(:,:,iW))
%     set(gca,'XTick', 1:length(allSubjectResults.chanNames), 'XTickLabel', allSubjectResults.chanNames)
%     set(gca,'YTick', 1:length(allSubjectResults.chanNames), 'YTickLabel', allSubjectResults.chanNames)
    colorbar
end