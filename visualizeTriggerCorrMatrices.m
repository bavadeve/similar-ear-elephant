

figure; 
subplot(1,2,1); 
imagesc(nanmean(allSubjectResults.corrMatrices.trigger11,3)); 
avgTrigger11 = nanmean(nanmean(nanmean(allSubjectResults.corrMatrices.trigger11,3)));
title(['trigger 11 avg: ' num2str(avgTrigger11)])
colorbar; 
subplot(1,2,2); 
imagesc(nanmean(allSubjectResults.corrMatrices.trigger12,3)); 
avgTrigger12 = nanmean(nanmean(nanmean(allSubjectResults.corrMatrices.trigger12,3)));
title(['trigger 12 avg: ' num2str(avgTrigger12)])
colorbar;