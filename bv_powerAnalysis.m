function bv_powerAnalysis(cfg, data)

inputStr 	= ft_getopt(cfg, 'inputStr');
outputStr   = ft_getopt(cfg, 'outputStr');
currSubject = ft_getopt(cfg, 'currSubject');
optionsFcn  = ft_getopt(cfg, 'optionsFcn');
freqOutput  = ft_getopt(cfg, 'freqOutput','fourier');
saveData    = ft_getopt(cfg, 'saveData');
nTrials     = ft_getopt(cfg, 'nTrials','all');
method      = ft_getopt(cfg, 'method');

if nargin < 2
    disp(currSubject)
    
    eval(optionsFcn)
    eval('setOptions')
    
    subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
    try
        [subjectdata, data] = bv_check4data(subjectFolderPath, inputStr);
    catch
        fprintf('\t previous data not found, skipping ... \n')
        connectivity = [];
        return
    end
    
    subjectdata.cfgs.(method) = cfg;
    
end

freq = bvLL_frequencyanalysis(data, [1 100], 'powandcsd') 
figure; plot(freq.freq, log10(abs(squeeze(nanmean(freq.powspctrm))))', 'LineWidth', 2)
set(gca, 'YLim', [-2 2])
set(gca, 'XLim', [0 20])

figure; plot(freq.freq, log10(abs(squeeze(nanmean(nanmean(freq.powspctrm),2))))', 'LineWidth', 2)
set(gca, 'YLim', [-2 2])
set(gca, 'XLim', [0 20])
