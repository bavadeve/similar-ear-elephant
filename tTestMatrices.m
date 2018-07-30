function tTestMatrix = tTestMatrices(allSubjectResults)

autismIdx = find(strcmp(allSubjectResults.condition, 'ASS') == 1);
controlIdx = find(strcmp(allSubjectResults.condition, 'Controle') == 1);
autismCorrMatrices = allSubjectResults.corrMatrices(:,:,autismIdx);
controlCorrMatrices = allSubjectResults.corrMatrices(:,:,controlIdx);

tTestMatrix = zeros(size(autismCorrMatrices,1), size(autismCorrMatrices,2));

for i = 1:size(autismCorrMatrices,1)
    for j = 1:size(autismCorrMatrices,2)
        currAutismVals = squeeze(autismCorrMatrices(i,j,:));
        currControlVals = squeeze(controlCorrMatrices(i,j,:));
        [~,~,~,stats] = ttest2(currControlVals,currAutismVals);
        tTestMatrix(i,j) = stats.tstat;
        clear currAutismVals currControlVals
    end
end

figure; imagesc(tTestMatrix)
set(gca, 'XTick', 1:length(allSubjectResults.chanNames));
set(gca, 'YTick', 1:length(allSubjectResults.chanNames));
set(gca, 'XTickLabel', allSubjectResults.chanNames);
set(gca, 'YTickLabel', allSubjectResults.chanNames);
colorbar();
title('ttest matrix')

[h,p,~,stats] = ttest(tTestMatrix(:));

disp(h)
disp(p)
disp(stats)