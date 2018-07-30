function setAxisTicks(ticklabels)

set(gca, 'XTick', 1:length(ticklabels), 'XTickLabel', ticklabels)
set(gca, 'YTick', 1:length(ticklabels), 'YTickLabel', ticklabels)
