function [ connectivity ] = bv_calculatePLI(cfg, data)

%%%%%% general check for inputs %%%%%%
ntrials     = ft_getopt(cfg, 'ntrials','all');
condition   = ft_getopt(cfg, 'condition', 'all');
currSubject = ft_getopt(cfg, 'currSubject');
inputStr    = ft_getopt(cfg, 'inputStr');
saveData    = ft_getopt(cfg, 'saveData', 'no');
outputStr   = ft_getopt(cfg, 'outputStr');
pathsFcn    = ft_getopt(cfg, 'pathsFcn', 'setPaths');
optionsFcn  = ft_getopt(cfg, 'optionsFcn', 'setOptions');
triallength = ft_getopt(cfg, 'triallength');
keeptrials  = ft_getopt(cfg, 'keeptrials', 'no');

% load in data if no input data is given
if nargin < 2
    disp(currSubject)
    eval(pathsFcn)
    eval(optionsFcn)
    
    subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
    try
        [subjectdata, data] = bv_check4data(subjectFolderPath, inputStr);
    catch
        fprintf('\t previous data not found, skipping ... \n')
        connectivity = [];
        return
    end
    subjectdata.cfgs.(outputStr) = cfg;
    
end

freqLabel = {'theta', 'alpha1'};
freqRng = {[3 6], [6 9]};

fprintf('\t loading in raw data ... \n')
cfg = [];
cfg.headerfile = subjectdata.PATHS.HDRFILE;
cfg.dataset = subjectdata.PATHS.DATAFILE;
cfg.channel = ['EEG'; strcat('-', subjectdata.channels2remove)];
cfg.reref = 'yes';
cfg.refchannel = 'all';
evalc('origdata = ft_preprocessing(cfg);');

fprintf(['\t repairing bad channels: ', ...
    repmat('%s ', 1, length(subjectdata.channels2remove)), '\n'], ...
    subjectdata.channels2remove{:})
cfg = [];
cfg.layout = 'biosemi32.lay';
cfg.method = 'triangulation';
evalc('neighbours = ft_prepare_neighbours(cfg);');

cfg = [];
cfg.missingchannel = subjectdata.channels2remove';
cfg.method = 'weighted';
cfg.neighbours = neighbours;
cfg.layout = 'biosemi32.lay';
evalc('origdata = ft_channelrepair(cfg, origdata);');

origdata = bv_sortBasedOnTopo(origdata);

fprintf('\t resampling original data to %1.0f Hz... \n', data.fsample)
cfg = [];
cfg.resamplefs = data.fsample;
evalc('origdata = ft_resampledata(cfg, origdata);');
    
% fprintf('\t rereferencing original data ... \n')
% cfg = [];
% cfg.reref = 'yes';
% cfg.refchannel = 'all';
% evalc('origdata = ft_preprocessing(cfg, origdata);');

for iFreq = 1:length(freqLabel)
    currFreq = freqLabel{iFreq};
    currFreqRng = freqRng{iFreq};
    fprintf('\t ******* filtering for %s ... ******* \n' , currFreq)
    cfg = [];
    cfg.lpfilter = 'yes';
    cfg.lpfreq = currFreqRng(2);
    cfg.hpfilter = 'yes';
    cfg.hpfreq = currFreqRng(1);
    cfg.hpinstabilityfix = 'reduce';
    evalc('origdata_filt = ft_preprocessing(cfg, origdata);');
    
    fprintf('\t cut out clean data according to input file ... \n')
    trl = [data.sampleinfo, zeros(size(data.sampleinfo,1),1), data.trialinfo];
    cfg = [];
    cfg.trl = trl;
    evalc('origdata_filt = ft_redefinetrial(cfg, origdata_filt);');
    
    % cut, if needed data into trials
    if ~isempty(triallength)
        cfg = [];
        cfg.saveData = 'no';
        cfg.triallength = triallength;
        cfg.ntrials = ntrials;
        [dataCut, finished] = bv_cutAppendedIntoTrials(cfg, origdata_filt);
        if ~finished
            connectivity = [];
            return;
        end
    else
        dataCut = origdata_filt;
    end
    
    if not(strcmpi(condition, 'all'))
        cfg = [];
        cfg.trials = find(ismember(dataCut.trialinfo, condition));
        evalc('dataCut = ft_selectdata(cfg, dataCut);');
    end
        
    fprintf('\t calculating PLI ... ')
    PLIs = PLI(dataCut.trial,1);
    PLIs = cat(3,PLIs{:});
    
    if strcmpi(keeptrials, 'yes')
        connectivity.plispctrm(:,:,:, iFreq) = PLIs;
        connectivity.dimord = 'chan_chan_trl_freq';
        connectivity.sampleinfo = dataCut.sampleinfo;
        connectivity.time = dataCut.time;
    else
        connectivity.plispctrm(:,:,iFreq) = mean(PLIs,3);
        connectivity.dimord = 'chan_chan_freq';
    end
    
    fprintf('done!\n')
end

connectivity.freq = freqLabel;
connectivity.freqRng = freqRng;
connectivity.label = dataCut.label;
connectivity.trialinfo = dataCut.trialinfo;

%         % find removed channels and add a row of nans
%         cfg = [];
%         cfg.layout = 'biosemi32.lay';
%         cfg.skipcomnt = 'yes';
%         cfg.skipscale = 'yes';
%         evalc('layout = ft_prepare_layout(cfg);');
%         rmChannels = layout.label(not(ismember(layout.label, connectivity.label)));
%         if not(isempty(rmChannels))
%             connectivity = addRemovedChannels(connectivity, rmChannels);
%         end

%%%%%% save data %%%%%%
if strcmpi(saveData, 'yes')
    
    outputFilename = [subjectdata.subjectName '_' outputStr '.mat'];
    fieldname = upper(outputStr);
    subjectdata.PATHS.(fieldname) = [subjectdata.PATHS.SUBJECTDIR filesep ...
        outputFilename];
    
    fprintf('\t saving %s ... ', outputFilename)
    save(subjectdata.PATHS.(fieldname), 'connectivity')
    fprintf('done! \n')
    
    analysisOrder = strsplit(subjectdata.analysisOrder, '-');
    analysisOrder = [analysisOrder outputStr];
    analysisOrder = unique(analysisOrder, 'stable');
    subjectdata.analysisOrder = strjoin(analysisOrder, '-');
    
    
    fprintf('\t saving subjectdata variable to Subject.mat ... ')
    save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'], 'subjectdata')
    fprintf('done! \n')
    if isfield(PATHS, 'SUMMARY')
        bv_updateSubjectSummary([PATHS.SUMMARY filesep 'SubjectSummary'], subjectdata)
    end
    
end

%%%%%% extra functions %%%%%%
function connectivity = addRemovedChannels(connectivity, trueRmChannels)

connectivity.label = cat(1,connectivity.label, trueRmChannels);

fnames = fieldnames(connectivity);
fname2use = fnames{not(cellfun(@isempty, strfind(fnames, 'spctrm')))};

currSpctrm = connectivity.(fname2use);
startRow = (size(currSpctrm,1) + 1);
endRow = (size(currSpctrm,1)) + length(trueRmChannels);
currSpctrm(1:size(currSpctrm,1), startRow:endRow, :) = NaN;
currSpctrm(startRow:endRow, 1:size(currSpctrm,2), :) = NaN;

cfg = [];
cfg.channel  = connectivity.label;
cfg.layout   = 'EEG1010';
cfg.feedback = 'no';
cfg.skipcomnt   = 'yes';
cfg.skipscale   = 'yes';
evalc('lay = ft_prepare_layout(cfg);');

[~, indxSort] = ismember(lay.label, connectivity.label);
indxSort = indxSort(any(indxSort,2));

currSpctrm = currSpctrm(indxSort, indxSort,:,:);
connectivity.label = connectivity.label(indxSort);
connectivity.(fname2use) = currSpctrm;