function bv_plotPower(cfg, data)

inputStr 	= ft_getopt(cfg, 'inputStr');
currSubject = ft_getopt(cfg, 'currSubject');
channel     = ft_getopt(cfg, 'channel', 'all');
optionsFcn  = ft_getopt(cfg, 'optionsFcn','setOptions');
pathsFcn    = ft_getopt(cfg, 'pathsFcn','setPaths');
calcMean    = ft_getopt(cfg, 'calcMean', 'yes');
freqRange   = ft_getopt(cfg, 'freqRange', [0 20]);

if nargin < 2
    disp(currSubject)
    
    eval(pathsFcn)
    eval(optionsFcn)
    
    subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
    
    try
        [subjectdata, data] = bv_check4data(subjectFolderPath, inputStr);
    catch
        error('inputStr data not found')
    end
else
    fprintf('Own input \n')
end

cfg = [];
cfg.channel = channel;
evalc('data = ft_selectdata(cfg, data);');

if isempty(data.label)
    fprintf('\t given channel not found for subject, skipping ... \n')
    return
end

output = 'pow';
fprintf('\t calculating frequency spectrum ...')
evalc('freq = bvLL_frequencyanalysis(data, freqRange, output);');
% figure; plot(freq.freq, log10(abs(squeeze(nanmean(freq.powspctrm))))', 'LineWidth', 2)
% set(gca, 'YLim', [-2 2])
% set(gca, 'XLim', [0 20])
fprintf('done! \n')

if strcmpi(calcMean, 'yes')
    plot(freq.freq, log10(abs(squeeze(nanmean(nanmean(freq.powspctrm),2))))', 'LineWidth', 2)
else
    plot(freq.freq, log10(abs(squeeze(nanmean(freq.powspctrm,1)))))
    legend(freq.label)
    set(gca, 'FontSize', 20)
end
% set(gca, 'YLim', [-1 2])
set(gca, 'XLim', [0 20])


