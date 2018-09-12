function bv_autoCorrSettings(ax, labels)

setAutoLimits(ax);
set(gca, 'XTick', 1:length(labels), 'XTickLabel', labels);
set(gca, 'YTick', 1:length(labels), 'YTickLabel', labels);
colorbar
axis square
