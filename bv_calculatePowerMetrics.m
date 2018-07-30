function pow = bv_calculatePowerMetrics(cfg, data)

inputStr 	= ft_getopt(cfg, 'inputStr');
currSubject = ft_getopt(cfg, 'currSubject');
channel     = ft_getopt(cfg, 'channel', 'all');
optionsFcn  = ft_getopt(cfg, 'optionsFcn','setOptions');
pathsFcn    = ft_getopt(cfg, 'pathsFcn','setPaths');
freqBands   = ft_getopt(cfg, 'freqBands', {[0.1 3], [3 6], [6 10]});
freqLabels  = ft_getopt(cfg, 'freqLabels', {'delta', 'theta', 'alpha'});
saveData    = ft_getopt(cfg, 'saveData', 'no');
outputStr   = ft_getopt(cfg, 'outputStr', 'powerdata');
saveFigure  = ft_getopt(cfg, 'saveFigure', 'no');
createFigure = ft_getopt(cfg, 'createFigure', 'yes');

if length(freqBands) ~= length(freqLabels)
    error('cfg.freqBands and cfg.freqLabels differ in length')
end

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

freqStart = max([min([freqBands{:}])-1 0]);
freqEnd   = max([freqBands{:}]);

output = 'pow';
fprintf('\t calculating frequency spectrum ...')
evalc('freq = bvLL_frequencyanalysis(data, [freqStart freqEnd], output);');
fprintf('done! \n')

freqIndx = find(ismember(freq.freq, [freqStart freqEnd]));
y_freq = squeeze(log((nanmean(freq.powspctrm(:,:,freqIndx(1):freqIndx(2)),1))));
x = freq.freq(freqIndx(1):freqIndx(2));
figure; plot(x, y_freq)
legend(freq.label)
y = log(squeeze(nanmean(nanmean(freq.powspctrm(:,:,freqIndx(1):freqIndx(2)),1),2)));

[peakVals,freqVals] = findpeaks(y,x);

fprintf('\t calculating powerdata characteristics ... \n')
allFreqs = [];
allHths = [];
minFreq = Inf;
for iF = 1:length(freqBands)
    currFreqBand = freqBands{iF};
    currFreqLabel = freqLabels{iF};
   
    fprintf('\t \t %s \n', currFreqLabel)
    
    peakIndx = find(freqVals>currFreqBand(1) & freqVals<currFreqBand(2));
    
    if isempty(peakIndx)
        peakFreq = NaN;
        peakHth = NaN;
    elseif length(peakIndx) > 1
        [~, i] = max(peakVals(peakIndx));
        peakFreq = freqVals(peakIndx(i));
        peakHth = peakVals(peakIndx(i));
    else
        peakFreq = freqVals(peakIndx);
        peakHth = peakVals(peakIndx);
    end
    
    x_curr = currFreqBand(1):0.1:currFreqBand(2);
    y_curr = interp1(x,y,x_curr);
        
    powerdata.(currFreqLabel).area = trapz(x_curr, y_curr);
    powerdata.(currFreqLabel).peakFreq = peakFreq;
    powerdata.(currFreqLabel).peakHth = peakHth;
    
    allFreqs = [allFreqs peakFreq];
    allHths = [allHths  peakHth];
end

if strcmpi(createFigure,'yes')
    fprintf('\t creating powerdata figure ... ')
    figure;
    plot(x, y, 'b', 'LineWidth', 2)
    hold on
    plot(allFreqs, allHths, 'dr', 'MarkerSize', 4, 'MarkerFaceColor', 'red' )
    text(allFreqs+.02,allHths+0.1,freqLabels)
    title([currSubject ' powerPeaks'])
    set(gca,'FontSize', 20)
    ylabel('Power (in dB)')
    xlabel('Frequency (in Hz)')
    fprintf('done! \n')
    set(gcf, 'Position', get(0, 'Screensize'));

    
    if strcmpi(saveFigure, 'yes');
        fprintf('\t \t saving figure ... ')
        saveas(gcf, [PATHS.FIGURES filesep currSubject '_' outputStr '.png'])
        fprintf('done! \n')
        close all
    end
end

if strcmpi(saveData, 'yes')
    
    bv_saveData(subjectdata, powerdata, outputStr)
    
end
    
