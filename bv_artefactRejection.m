function [data, artefactdef, counts] = bv_artefactRejection(cfg, data)

betaLim         = ft_getopt(cfg, 'betaLim', Inf);
gammaLim        = ft_getopt(cfg, 'gammaLim', Inf);
varLim          = ft_getopt(cfg, 'varLim', Inf);
invVarLim       = ft_getopt(cfg, 'invVarLim', Inf);
kurtLim         = ft_getopt(cfg, 'kurtLim', Inf);
flatLim         = ft_getopt(cfg, 'flatLim', Inf);
optionsFcn      = ft_getopt(cfg, 'optionsFcn');
triallength     = ft_getopt(cfg, 'triallength');
saveFigures     = ft_getopt(cfg, 'saveFigures');
showFigures     = ft_getopt(cfg, 'showFigures');
currSubject     = ft_getopt(cfg, 'currSubject');
inputStr        = ft_getopt(cfg, 'inputStr');
outputStr       = ft_getopt(cfg, 'outputStr');
saveData        = ft_getopt(cfg, 'saveData');
rmTrials        = ft_getopt(cfg, 'rmTrials');
cutOutputData   = ft_getopt(cfg, 'cutOutputData');
zScoreLim       = ft_getopt(cfg, 'zScoreLim');
vMaxLim         = ft_getopt(cfg, 'vMaxLim');
redefineTrial   = ft_getopt(cfg, 'redefineTrial');

if isempty(triallength);    error('no cfg.triallength given'); end

if sum(isinf([betaLim gammaLim varLim invVarLim kurtLim flatLim zScoreLim vMaxLim])) == length([betaLim gammaLim varLim invVarLim kurtLim zScoreLim vMaxLim flatLim])
    warning('No limits given so no artefacts will be detected')
end

disp(currSubject)

if nargin < 2
    if isempty(optionsFcn)
        error('please add options function cfg.optionsFcn')
    else
        eval(optionsFcn)
    end
    
    subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
    [subjectdata, data] = bv_check4data(subjectFolderPath, inputStr);
    
    subjectdata.cfgs.(outputStr) = cfg;
end

output = 'pow';
oldData = data;

if redefineTrial
    fprintf('\t redefining triallength to %s seconds ... ', num2str(triallength))
    cfg = [];
    cfg.length = triallength;
    cfg.overlap = 0;
    evalc('data = ft_redefinetrial(cfg, oldData);');
    fprintf('done! \n')
else
    fprintf('\t trials already present, no redefining necessary \n')
end

fprintf('\t artefact calculation \n')
fprintf('\t\t frequency calculation ... ')

freqrange = [2 100];
evalc('freq = bvLL_frequencyanalysis(data, freqrange, output);');

freqFields  = fieldnames(freq);
field2use   = freqFields{not(cellfun(@isempty, strfind(freqFields, 'spctrm')))};

fprintf('done! \n')

fprintf('\t\t artefact determination ... ')
cfg = [];
cfg.betaLim     = betaLim;
cfg.gammaLim    = gammaLim;
cfg.varLim      = varLim;
cfg.invVarLim   = invVarLim;
cfg.kurtLim     = kurtLim;
cfg.zScoreLim   = zScoreLim;
cfg.vMaxLim     = vMaxLim;
cfg.flatLim     = flatLim;

evalc('[artefactdef, counts] = bvLL_artefactDetection(cfg, data, freq);');
fprintf('done! \n')


if strcmpi(showFigures, 'yes')
    
    if exist('findCoords', 'file')
        [xScreenLength, yScreenLength] = findCoords;
    else
        xScreenLength = 1;
        yScreenLength = 1;
    end
    
    fprintf('\t creating and plotting figures for artefacts \n')
    fprintf('\t\t creating frequency spectrum plot ...')
    
    figure; plot(freq.freq, log10(abs(squeeze(nanmean(freq.(field2use)))))', 'LineWidth', 2)
    legend(data.label)
    set(gca, 'YLim', [-4 Inf])
    %     set(gcf, 'units', 'normalized', 'Position', [0 0 xScreenLength/2 yScreenLength])
    fprintf('done! \n')
    
    if strcmpi(saveFigures, 'yes')
        fprintf('\t\t\t saving ... ')
        set(gcf, 'Position', get(0, 'Screensize'));
        saveas(gcf, [PATHS.FIGURES filesep currSubject '_' inputStr '_freqDirty.png'])
        fprintf('done! \n')
        close all
    end
    
    % figure;
    fprintf('\t\t creating scrollplot with artefacts in red ... ')
    %     addpath('~/git/eeg-graphmetrics-processing/figures/')
    cfg = [];
    cfg.badPartsMatrix  = artefactdef.badPartsMatrix;
    cfg.horzLim         = 'full';
    cfg.scroll          = 0;
    cfg.visible         = 'on';
    cfg.triallength     = triallength;
    scrollPlot          = scrollPlotData(cfg, data);
    fprintf('done! \n')
    %     set(gcf, 'units', 'normalized', 'Position', [xScreenLength/2 yScreenLength xScreenLength/2 yScreenLength])
    
    %
    %     cfg = [];
    %     cfg.viewmode = 'vertical';
    %     ft_databrowser(cfg, oldData);
    %
    %     fprintf('\t please press SPACE to continue ... ')
    %     pause
    %     fprintf('done! \n')
    
    if strcmpi(saveFigures,'yes')
        fprintf('\t\t\t saving ... ')
        %         set(gcf, 'Position', get(0,'Screensize'));
        saveas(gcf, [PATHS.FIGURES filesep currSubject '_' inputStr '_dataDirty.png'])
        fprintf('done! \n')
        close all
    end
end

badTrialsPerChannel = hist(artefactdef.badPartsMatrix(:,2),1:length(data.label));
pBadTrials = badTrialsPerChannel / length(data.trial);
chans2remove = data.label(pBadTrials > 0.4);
flatliners = data.label((sum(artefactdef.flatline.levels > flatLim,2) ./ length(data.trial)>0.4));

if isfield(subjectdata, 'flatliners')
    subjectdata.flatliners = unique(cat(1,subjectdata.flatliners, flatliners));
else
    subjectdata.flatliners = flatliners;
end

if ~length(chans2remove) == 0
    fprintf(['\t channels to remove: ' repmat('%s ', 1, length(chans2remove)) '... \n'], chans2remove{:})
    
    if isfield(subjectdata, 'rmChannels')
        subjectdata.rmChannels = reshape(subjectdata.rmChannels,length(subjectdata.rmChannels), 1);
        subjectdata.rmChannels = cat(1, subjectdata.rmChannels, chans2remove);
        subjectdata.rmChannels = unique(subjectdata.rmChannels);
    else
        subjectdata.rmChannels = chans2remove;
    end
    
    keepChannelIndx = ~ismember(data.label, chans2remove);
    
    if sum(keepChannelIndx) == 0
        removingSubjects([], currSubject, 'No artefact free trials')
        return
    end
    
    cfg = [];
    cfg.channel = find(keepChannelIndx);
    
    if strcmpi(cutOutputData, 'yes')
        
        evalc('data = ft_selectdata(cfg, data);');
        
        fprintf('\t recalculating artefacts with channels removed \n')
        
        fprintf('\t\t frequency calculation ... ')
        evalc('freq = bvLL_frequencyanalysis(data, freqrange,output);');
        fprintf('done! \n')
        
        fprintf('\t\t artefact determination ... ');
        cfg = [];
        cfg.betaLim     = betaLim;
        cfg.gammaLim    = gammaLim;
        cfg.varLim      = varLim;
        cfg.invVarLim   = invVarLim;
        cfg.kurtLim     = kurtLim;
        cfg.zScoreLim   = zScoreLim;
        
        evalc('[artefactdef, counts] = bvLL_artefactDetection(cfg, data, freq);');
        
    else
        
        evalc('data = ft_selectdata(cfg, oldData);');
        
        
        if strcmpi(showFigures, 'yes');
            fprintf('\t showing cleaned frequency spectrum ... ')
            
            if redefineTrial
                cfg = [];
                cfg.length  = 5;
                cfg.overlap = 0;
                evalc('dataCut = ft_redefinetrial(cfg, data);');
            else
                dataCut = data;
            end
            
            evalc('freq = bvLL_frequencyanalysis(dataCut, freqrange,output);');
            
            figure; plot(freq.freq, log10(abs(squeeze(mean(freq.(field2use)))))', 'LineWidth', 2)
            legend(data.label)
            set(gca, 'YLim', [-4 Inf])
            set(gcf, 'units', 'normalized', 'Position', [0 0 xScreenLength/2 yScreenLength])
            
            fprintf('done! \n')
            drawnow;
        end
    end
else
    fprintf('\t No channels to REMOVE! \n')
    
    if ~strcmpi(cutOutputData, 'yes')
        data = oldData;
    end
    
end

if strcmpi(rmTrials, 'yes')
    
    subjectdata.goodTrials = artefactdef.goodTrials';
    subjectdata.badTrials = artefactdef.badTrials;
    
    
    fprintf('\t removing artefactridden trials ... ')
    cfg = [];
    cfg.trials = artefactdef.goodTrials;
    evalc('data = ft_selectdata(cfg, data);');
    fprintf('done! \n')
    
    if strcmpi(showFigures, 'yes')
        fprintf('\t creating and plotting cleaned figures \n')
        
        fprintf('\t\t creating clean frequency spectrum plot ... ')
        evalc('freq = bvLL_frequencyanalysis(data, freqrange,output);');
        
        figure; plot(freq.freq, log10(abs(squeeze(mean(freq.(field2use)))))', 'LineWidth', 2)
        legend(data.label)
        set(gca, 'YLim', [-4 Inf])
        fprintf('done! \n')
        
        if strcmpi(saveFigures, 'yes')
            fprintf('\t\t\t saving ... ')
            set(gcf, 'Position', get(0, 'Screensize'));
            saveas(gcf, [PATHS.FIGURES filesep currSubject '_' inputStr '_freqClean.png'])
            fprintf('done! \n')
            close all
        end
        
        fprintf('\t\t creating clean scrollplot ... ');
        cfg = [];
        cfg.betaLim     = betaLim;
        cfg.gammaLim    = gammaLim;
        cfg.varLim      = varLim;
        cfg.invVarLim   = invVarLim;
        cfg.kurtLim     = kurtLim;
        cfg.zScoreLim   = zScoreLim;
        cfg.vMaxLim     = vMaxLim;
        
        evalc('[artefactdef, counts] = bvLL_artefactDetection(cfg, data, freq);');
        
        % figure;
        %         addpath('~/git/eeg-graphmetrics-processing/figures/')
        cfg = [];
        cfg.badPartsMatrix  = artefactdef.badPartsMatrix;
        cfg.horzLim         = 'full';
        %         cfg.triallength     = 1;
        cfg.scroll          = 0;
        cfg.visible         = 'on';
        cfg.triallength     = 5;
        scrollPlot          = scrollPlotData(cfg, data);
        fprintf('done! \n')
        
        if strcmpi(saveFigures, 'yes')
            fprintf('\t\t\t saving ... ')
            set(gcf, 'Position', get(0, 'Screensize'));
            saveas(gcf, [PATHS.FIGURES filesep currSubject '_' inputStr '_dataClean.png'])
            fprintf('done! \n')
            close all
        end
        
    end
    
    if strcmpi(saveData, 'yes')
        outputStrPathName = upper(outputStr);
        
        
        
        dataFilename = [currSubject '_' outputStr '.mat'];
        artefactdefFilename = [currSubject '_artefactdef.mat'];
        subjectdata.PATHS.(outputStrPathName) = [subjectdata.PATHS.SUBJECTDIR filesep dataFilename];
        subjectdata.PATHS.ARTEFACTDEF = [subjectdata.PATHS.SUBJECTDIR filesep artefactdefFilename];
        
        fprintf('\t saving %s ... ', dataFilename)
        save(subjectdata.PATHS.(outputStrPathName), 'data')
        fprintf('done! \n')
        
        fprintf('\t saving %s ... ', artefactdefFilename)
        save(subjectdata.PATHS.ARTEFACTDEF, 'artefactdef')
        fprintf('done! \n')
        
        analysisOrder = strsplit(subjectdata.analysisOrder, '-');
        analysisOrder = [analysisOrder outputStr];
        analysisOrder = unique(analysisOrder, 'stable');
        subjectdata.analysisOrder = strjoin(analysisOrder, '-');
        
        fprintf('\t saving Subject.mat ... ')
        save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'] , 'subjectdata')
        fprintf('done! \n')
    end
else
    if strcmpi(saveData, 'yes')
        
        outputStrPathName = upper(outputStr);
        
        dataFilename = [currSubject '_' outputStr '.mat'];
        subjectdata.PATHS.(outputStrPathName) = [subjectdata.PATHS.SUBJECTDIR filesep dataFilename];
        
        fprintf('\t saving %s ... ', dataFilename)
        save(subjectdata.PATHS.(outputStrPathName), 'data')
        fprintf('done! \n')
        
        analysisOrder = strsplit(subjectdata.analysisOrder, '-');
        analysisOrder = [analysisOrder outputStr];
        analysisOrder = unique(analysisOrder, 'stable');
        subjectdata.analysisOrder = strjoin(analysisOrder, '-');
        
        fprintf('\t saving Subject.mat ... ')
        save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'] , 'subjectdata')
        fprintf('done! \n')
    end
end



fprintf('\t all done! \n')

close all
clear subjectdata

