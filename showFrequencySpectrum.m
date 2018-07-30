function freqSpectrum = showFrequencySpectrum(data)

if length(data.trial{1}) > data.fsample
    cfg = [];
    cfg.length = 1;
    cfg.overlap = 0;
    evalc('data = ft_redefinetrial(cfg, data);');
end

cfg = [];
cfg.method      = 'mtmfft';
cfg.taper       = 'hanning';
cfg.output      = 'pow';
cfg.tapsmofrq   = 10;
cfg.foilim      = [1 100];
cfg.keeptrials  = 'yes';
evalc('freq = ft_freqanalysis(cfg, data);');

[~, sortIdx] = sort(squeeze(mean(mean(freq.powspctrm(:,:,:),1),3)), 'descend');

freqSpectrum = figure('Visible', 'on');
plot(freq.freq, squeeze(mean(freq.powspctrm(:,sortIdx,:),1)))
title(['frequencypower spectrum']);
legend(freq.label(sortIdx))
set(gca, 'FontSize', 20, 'YLim', [0 max(squeeze(mean(mean(freq.powspctrm,1),2)))])
set(gcf, 'Position', get(0,'Screensize'))
