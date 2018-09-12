function [ data, subjectdata ] = bv_preprocResample(cfg)
% bv_preprocResample reads-in, preprocesses (and resamples) raw EEG data,
% based on FT_PREPROCESSING of the fieldtrip toolbox and applies several
% user-specified preprocessing steps to the signals. The function uses
% subject information (stored in an individual Subject.mat file) gathered
% with the BV_CREATESUBJECTFOLDERS, so please run that function first.
% Order of preprocessing:
%           1) resampling
%           2) filtering
%           3) rereferencing
%
% Use as
% [ data ] = bv_preprocResample( cfg )
%
% The input argument cfg is a configuration structure, which contains all
% details for the preprocessing of the dataset.
%
% This function can be ran in two different ways. 1) Running after
% BV_CREATESUBJECTFOLDERS has been ran, which creates unique subject
% folders for each participant and saves a unique Subject.mat file in each
% folder with subjectdata pertaining the experiment. 2) Running with a
% dataset and hdrfile input. *IMPORTANT*, since there is in this case, no
% personal subject folder. The data wil not be automatically saved. The
% output data-file needs to be saved afterwards.
%
% For the first option the configuration structure needs to contain:
%   cfg.currSubject     = 'string': subject folder name of the subject to
%                           be analyzed
%   cfg.pathsFcn        = 'string': filename of m-file to be read with all
%                           necessary paths to run this function (default:
%                           'setPaths'). Take care to add your trialfun
%                           to your matlab path). For an example options
%                           fcn see setPaths.m
%   cfg.saveData        = 'string': specifies whether data needs to be
%                           saved to personal folder ('yes' or 'no',
%                           default: 'no')
%   cfg.outputStr       = 'string': addition to filename when saving, so
%                           that the output filename becomes [currSubject
%                           outputStr .mat]. Outputstr is also used used to
%                           save path two outputfile in the individuals
%                           Subject.mat file (default: 'preproc')
%
% For the second option the configuration structure needs to contain:
%   cfg.dataset         = 'string': filename of the dataset to be used
%   cfg.headerfile      = 'string': filename of the headerfile to be used
%
% Input arguments that can be specified in both cases
%   cfg.trialfun        = 'string': filename of trialfun to be used for
%                           the preprocessing (take care to add your
%                           trialfun to your matlab path). See for example
%                           TRIALFUN_YOUTH_3Y. If the creation of trials is
%                           unnecessary, leave empty.
%
% Input arguments that should be specified when resampling data
%   cfg.resampleFs      = [ double ]: specify new sampling rate (default:
%                           no resampling)
%
% Input arguments that should be specified when filtering data
%   cfg.hpfreq          = [ double ]: high-pass filter frequency cut-off,
%                           (default: no high-pass filtering)
%   cfg.lpfreq          = [ double ]: low-pass filter frequency cut-off,
%                           (default: no low-pass filtering)
%   cfg.notchfreq       = [ double ]: notch filter frequency, (default: no
%                           notch filter)
%   cfg.filttype        = 'string': filter type, possible options 'but'
%                           (two-pass butterworth filter) or 'firws' (fir
%                           windowed sync). (default: 'but')
%
% Input arguments that should be specified when referencing data
%   cfg.reref           = 'string': specifies whether data needs to be
%                           rereferenced ('yes' or 'no', default: 'no')
%   cfg.refelec         = 'string' or { cell }: with EEG rereference
%                           channel(s), can be 'all' for common average
%                           reference (default: 'all')
%
%
% Optional input arguments
%   cfg.rmChannels      = 'string' or { cell }: Nx1 cell-array with
%                           channels to be removed before preprocessing
%                           (default = {}), see FT_CHANNELSELECTION for
%                           extra details
%
%
% See also BV_CREATESUBJECTFOLDERS, BV_SORTBASEDONTOPO,
% BV_RESAMPLEEEGDATA, BV_SAVEDATA, BV_FILTEREEGDATA, FT_CHANNELSELECTION,
% FT_PREPROCESSING,FT_RESAMPLEDATA

global PATHS

% read in data from configuration file and (if necessary) set defaults
currSubject = ft_getopt(cfg, 'currSubject');
pathsFcn    = ft_getopt(cfg, 'pathsFcn');
trialfun    = ft_getopt(cfg, 'trialfun');
triggervalue = ft_getopt(cfg, 'triggervalue');
triggerlabel = ft_getopt(cfg, 'triggerlabel');
saveData    = ft_getopt(cfg, 'saveData', 'no');
outputStr   = ft_getopt(cfg, 'outputStr', 'preproc');
resampleFs  = ft_getopt(cfg, 'resampleFs');
hpfreq      = ft_getopt(cfg, 'hpfreq');
lpfreq      = ft_getopt(cfg, 'lpfreq');
notchfreq   = ft_getopt(cfg, 'notchfreq');
filttype    = ft_getopt(cfg, 'filttype', 'but');
reref       = ft_getopt(cfg, 'reref', 'no');
refelec     = ft_getopt(cfg, 'refelec', 'all');
rmChannels  = ft_getopt(cfg, 'rmChannels');
dataset     = ft_getopt(cfg, 'dataset');
hdrfile     = ft_getopt(cfg, 'hdrfile');
overwrite   = ft_getopt(cfg, 'overwrite');

analysisOrd = {};

if ~isempty(dataset) && ~isempty(hdrfile)
    fprintf('running with raw \n \t dataset: %s and \n \t hdrfile: %s \n ', ...
        dataset, hdrfile)
    fprintf('**********************************************************\n')
    fprintf('\n')
    hasdata = 1;
    if strcmpi(saveData, 'yes')
        warning('data can not be saved when given dataset and hdrfile inputs, not saving ... ')
        saveData = 'no';
    end
else
    if isempty(currSubject)
        error('no dataset and hdrfile given, while no currSubject is known')
    end
    %     fprintf('running with subject.mat file of %s ', currSubject)
    hasdata = 0;
end

if ~hasdata % check whether data needs to be loaded from subject.mat file
    
    eval(pathsFcn) % get paths necessary to run function
    
    % Try to load in individuals Subject.mat. If unknown --> throw error.
    try
        load([PATHS.SUBJECTS filesep currSubject filesep 'Subject.mat'])
    catch
        error('Subject.mat file not found')
    end
    
    disp(subjectdata.subjectName)
    if ~overwrite
        if isfield(subjectdata.PATHS, upper(outputStr))
            if exist(subjectdata.PATHS.(upper(outputStr)), 'file')
                fprintf('\n\t %s already found, not overwriting ... \n', upper(outputStr))
                data = [];
                return
            end
        end
    end
    
    
    fprintf('\t Setting up for preprocessing ... ')
    
    hdrfile = subjectdata.PATHS.HDRFILE;
    dataset = subjectdata.PATHS.DATAFILE;
    
    fprintf('done! \n')
end

subjectdata.cfgs.(outputStr) = cfg; % save used config file in subjectdata
subjectdata.rmChannels = rmChannels'; % save possible removed channels in subjectdata

fprintf('\t loading in data and rereferencing... ')
cfg = []; % start new cfg file for loading data

% only read in EEG data (without possible removed channels)
if ~isempty(rmChannels)
    cfg.channel = cat(2,'EEG', strcat('-',rmChannels));
else
    cfg.channel = cat(2,'EEG');
end

cfg.dataset = dataset;
cfg.headerfile = hdrfile;
cfg.continuous = 'yes';

if strcmpi(reref, 'yes')
    
    fprintf('\n \t \t rereferencing to %s electrode ... ', refelec)
    cfg.reref = 'yes';
    cfg.refchannel = refelec;
    
    analysisOrd = [analysisOrd, 'reref'];
    
end

% cfg.refchannel = 'all';
evalc('data = ft_preprocessing(cfg);');
fprintf('done! \n')

data = bv_sortBasedOnTopo(data); % sorting data based on actual place of the electrodes. See function or more detail.


% *** Resampling (if a resampleFs is edogiven)
if ~isempty(resampleFs)
    
    % important steps to take to ensure sample info can be used after
    % resampling. 1) adding a channel to the original data that contains
    % sample indices of the original data set (1:ntotalsamples). 2)
    % downsampling causes this sample indices also to be downsampled.
    % Therefore giving you he mapping between the new and the old samples
    % (see https://mailman.science.ru.nl/pipermail/fieldtrip/2016-March/010263.html)
    % Check BV_RESAMPLEEEGDATA for analysis
    
    cfg = [];
    cfg.resampleFs = resampleFs;
    
    [ data  ] = bv_resampleEEGdata( cfg , data );
    
    analysisOrd = [analysisOrd, 'res']; % managing analysis order to be saved later
    
end

% *** Filtering data (if a hpfreq, lpfreq, or notchfreq is given).
% See BV_FILTEREEGDATA for more info
if ~isempty(hpfreq) || isempty(lpfreq) || isempty(notchfreq)
    
    cfg.hpfreq      = hpfreq;
    cfg.lpfreq      = lpfreq;
    cfg.notchfreq   = notchfreq;
    cfg.filttype    = filttype;
    
    data = bv_filterEEGdata(cfg, data);
    
    analysisOrd = [analysisOrd, 'filt']; % managing analysis order to save later
end

fprintf('done!\n')
% *** cut data into trials based on trialfun
% Your trialfun detects the epochs in your data and adds them to a trl
% variable. It's very important that if you've resampled your data, you use your
% updated sample info. See for example trialfun_YOUth_3Y. In this trialfun
% the event codes (and sample info) are read in from the raw EEG files and
% converted to resampled values. These are used in ft_redefinetrial to
% redefine the trialstructure of the data file
if ~isempty(trialfun)
    fprintf('\t Redefining trialstructure based on %s ... \n', trialfun)
    
    subjectdata.trialfun = trialfun;
    
    cfg = [];
    cfg.dataset = dataset;
    cfg.headerfile = hdrfile;
    cfg.trialfun = trialfun;
    cfg.Fs = resampleFs;
    cfg.trialdef.eventvalue = triggervalue;
    cfg.trialdef.eventlabel = triggerlabel;
    
    try
        evalc('cfg = ft_definetrial(cfg)');
        
    catch
        fprintf('\n \t \t no trials found, removing subject and continueing ... \n')
        cfg = [];
        cfg.optionsFcn = 'setOptions';
        cfg.pathsFcn = 'setPaths';
        removingSubjects(cfg, currSubject, 'no trials found')
        return
    end
    
    bv_showTrialAmount(cfg)
    
    evalc('data = ft_redefinetrial(cfg, data);');
    
    analysisOrd = [analysisOrd, 'trial']; % managing analysis order to save later
    
end


% **** saving data
if strcmpi(saveData, 'yes')
    
    subjectdata.analysisOrder = strjoin(analysisOrd, '-');  % add analysis order so far to subjectdata
    
    bv_saveData(subjectdata, data, outputStr);              % save both data and subjectdata to the drive
    
end