function data = bv_removeComps(cfg, data, comp)

currSubject         = ft_getopt(cfg, 'currSubject');
optionsFcn          = ft_getopt(cfg, 'optionsFcn');
saveData            = ft_getopt(cfg, 'saveData');
outputStr           = ft_getopt(cfg, 'outputStr');
dataStr             = ft_getopt(cfg, 'dataStr');
compStr             = ft_getopt(cfg, 'compStr');
automaticRemoval    = ft_getopt(cfg, 'automaticRemoval');
saveFigure          = ft_getopt(cfg, 'saveFigure');

if strcmpi(automaticRemoval, 'yes')
    automaticFlag = 1;
else
    automaticFlag = 0;
end

if nargin < 3
    
    disp(currSubject)
    eval(optionsFcn)
    subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
    
    if isempty(dataStr)
        error('cfg.dataStr not given while also no data input variable given')
    end
    if isempty(compStr)
        error('cfg.compStr not given while also no data input variable given')
    end
    if isempty(currSubject)
        error('no cfg.currSubject while also no data/comp input variable given')
    end
    
    [subjectdata, data, comp] = bv_check4data(subjectFolderPath, dataStr, compStr);
end

oldcfg = cfg;

xScreenLength = 1;
yScreenLength = 1;

if exist('WindowSize', 'file')
    [xScreenSize, yScreenSize] = WindowSize(0);
    set(0, 'units', 'pixels')
    realScreenSize = get(0, 'ScreenSize');
    xDiff = xScreenSize / realScreenSize(3);
    xScreenLength = xScreenLength * xDiff;
    yDiff = yScreenSize / realScreenSize(4);
    yScreenLength = yScreenLength * yDiff;
end

fprintf('\t creating frequency plot ... ')

output = 'pow';
freqrange = [2 100];
evalc('freq = bvLL_frequencyanalysis(data, freqrange, output, 1);');

freqFields  = fieldnames(freq);
field2use   = freqFields{not(cellfun(@isempty, strfind(freqFields, 'spctrm')))};

figure; plot(freq.freq, log10(abs(squeeze(nanmean(freq.(field2use)))))', 'LineWidth', 2)
legend(data.label)
set(gca, 'YLim', [-4 Inf])
set(gcf, 'units', 'normalized', 'Position', [0 0 xScreenLength yScreenLength])

cfg = [];
cfg.fighandle   = gcf;
cfg.outputStr   = outputStr;
cfg.filename    = [currSubject '_freq_before'];
cfg.figtitle    = strrep(cfg.filename, '_','-');

bv_saveFigures(cfg)

fprintf('done! \n')

if automaticFlag
    fprintf('\t automatic component removal started ... \n')
    
    cfg = [];
    cfg.blinkremoval = 'no';
    cfg.gammaremoval = 'yes';
    
    rmComps = automaticCompRemoval(cfg, data, comp);
    
else

    fprintf('\t preparing layout...')
    cfg = [];
    cfg.channel  = data.label;
    cfg.layout   = 'EEG1010';
    cfg.feedback = 'no';
    cfg.skipcomnt  = 'yes';
    cfg.skipscale  = 'yes';
    evalc('lay = ft_prepare_layout(cfg);');
    fprintf('done! \n')
    
    fprintf('\t showing components ... \n')
    
    cfg = [];
    cfg.component = 1:length(comp.label); % specify the component(s) that should be plotted
    cfg.layout    = 'EEG1010'; % specify the layout file that should be used for plotting
    cfg.comment   = 'no';
    cfg.compscale = 'local';
    cfg.interactive = 'no';
    figure();
    evalc('ft_topoplotIC(cfg, comp);');
    set(gcf, 'units', 'normalized', 'Position', [xScreenLength/2 yScreenLength xScreenLength/2 yScreenLength])
    
    cfg = [];
    cfg.badPartsMatrix  = [];
    cfg.horzLim         = 60;
    cfg.scroll          = 1;
    cfg.visible         = 'on';
    cfg.channel         = 'all';
    fig2 = scrollPlotData(cfg, comp);
    
    fprintf('\t press SPACE after inspecting components \n')
    pause;
    
    
    inputStr = sprintf('\t Input component numbers to be removed, seperated by a comma. ');
    
    rmComps = input(inputStr', 's');
    rmComps = strrep(rmComps, ' ', '');
    rmComps = strsplit(rmComps, ',');
    rmComps = str2double(rmComps);
    
end


if ~isnan(rmComps)
    rmComps = unique(rmComps);

    rmCompIndx = rmComps;
    
    cfg = [];
    cfg.badPartsMatrix  = [ones(length(rmComps), 1), rmCompIndx'];
    cfg.horzLim         = 60;
    cfg.scroll          = 0;
    cfg.visible         = 'on';
    cfg.channel         = 'all';
    fig1 = scrollPlotData(cfg, comp);
    set(gcf, 'units', 'normalized', 'Position', [xScreenLength/2 yScreenLength xScreenLength/2 yScreenLength])
    
    cfg = [];
    cfg.component = rmComps; % specify the component(s) that should be plotted
    cfg.layout    = 'EEG1010'; % specify the layout file that should be used for plotting
    cfg.comment   = 'no';
    cfg.compscale = 'local';
    cfg.interactive = 'no';
    fig2 = figure();
    evalc('ft_topoplotIC(cfg, comp);');
    set(gcf, 'units', 'normalized', 'Position', [0 0 xScreenLength/2 yScreenLength])
    
    
    if strcmpi(saveFigure, 'yes')
        
        filename = [currSubject '_badComponentsTrial.png'];
        cfg = [];
        cfg.fighandle   = fig1;
        cfg.outputStr   = outputStr;
        cfg.filename    = filename;
        bv_saveFigures(cfg)
        
        filename = [currSubject '_badComponentsTopo.png'];
        cfg = [];
        cfg.fighandle   = fig2;
        cfg.outputStr   = outputStr;
        cfg.filename    = filename;
        bv_saveFigures(cfg)
        
    end
    
    badComponents = strread(num2str(rmComps),'%s');
    
    fprintf(['\t removing component(s): ' repmat('%s ',1,length(badComponents)), ...
        ' ... '], badComponents{:})
    
    badComponents = cellfun(@str2num, badComponents);
    oldcfg.removedComps = badComponents;
    
    cfg             = [];
    cfg.component   = badComponents;
    evalc('data = ft_rejectcomponent(cfg,comp,data);');
    
    fprintf('done! \n')
    
    
    output = 'pow';
    freqrange = [2 100];
    evalc('freq = bvLL_frequencyanalysis(data, freqrange, output, 1);');
    
    freqFields  = fieldnames(freq);
    field2use   = freqFields{not(cellfun(@isempty, strfind(freqFields, 'spctrm')))};
    
    fig3 = figure; plot(freq.freq, log10(abs(squeeze(nanmean(freq.(field2use)))))', 'LineWidth', 2)
    legend(data.label)
    set(gca, 'YLim', [-4 Inf])
    set(fig3, 'units', 'normalized', 'Position', [0 0 xScreenLength yScreenLength])
    
    drawnow;
    
    
    if strcmpi(saveFigure, 'yes')
        cfg = [];
        cfg.fighandle   = fig3;
        cfg.outputStr   = outputStr;
        cfg.filename    = [currSubject '_freq_after'];
        cfg.figtitle    = strrep(cfg.filename, '_','-');
        bv_saveFigures(cfg)
        
        close all
    end
    
    if strcmpi(saveData, 'yes')
        
        subjectdata.rmComps = badComponents;
        
        cRemFilename = [currSubject '_' outputStr '.mat'];
        subjectdata.PATHS.COMPREMOVED = [subjectdata.PATHS.SUBJECTDIR filesep cRemFilename];
        
        fprintf('\t Saving %s ... ', cRemFilename)
        save(subjectdata.PATHS.COMPREMOVED, 'data')
        fprintf('done! \n')
        
        analysisOrder = strsplit(subjectdata.analysisOrder, '-');
        analysisOrder = [analysisOrder outputStr];
        analysisOrder = unique(analysisOrder, 'stable');
        subjectdata.analysisOrder = strjoin(analysisOrder, '-');
        
        subjectdata.cfgs.(outputStr) = oldcfg;
        fprintf('\t Saving Subject.mat ... ')
        save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'], 'subjectdata')
        fprintf('done! \n')
    end
else
    if strcmpi(saveData, 'yes')
        
        subjectdata.rmComps = [];
        
        cRemFilename = [currSubject '_' outputStr '.mat'];
        subjectdata.PATHS.COMPREMOVED = [subjectdata.PATHS.SUBJECTDIR filesep cRemFilename];
        
        fprintf('\t Saving %s ... ', cRemFilename)
        save(subjectdata.PATHS.COMPREMOVED, 'data')
        fprintf('done! \n')
        
        analysisOrder = strsplit(subjectdata.analysisOrder, '-');
        analysisOrder = [analysisOrder outputStr];
        analysisOrder = unique(analysisOrder, 'stable');
        subjectdata.analysisOrder = strjoin(analysisOrder, '-');
        
        subjectdata.cfgs.(outputStr) = oldcfg;
        
        subjectdata.cfgs.(outputStr) = oldcfg;
        fprintf('\t Saving Subject.mat ... ')
        save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'], 'subjectdata')
        fprintf('done! \n')
    end
end
