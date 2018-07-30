function  visualInspection(cfg)
% visualize the power spectrum of given data
%
% Use as
%   visualizeFreqPowSpctrm(cfg)
%
% Additional options should be specified in and configuration struct and
% can be:
%
%   cfg.subjects:       [vector] add vector with the number of the
%                           subjects to be analyzed. Use 'all' if all
%                           subjects need to be analyzed (default:
%                           'all').
%   cfg.triallength:    [double] set the length of the default cut
%                           trials in seconds.
%   cfg.tapsmofrq:      [double] number, the amount of spectral smoothing
%                           through multi-tapering. Note that 4 Hz smoothing
%                           means plus-minus 4 Hz, i.e. a 8 Hz smoothing box.
%   cfg.freqrange:      [vector] frequency range
%   cfg.dataStr         [string] unique string where the data to be
%                           analyzed's filename is ending in
%
%
%

% get options
subjects                = ft_getopt(cfg, 'subjects', 'all');
filter                  = ft_getopt(cfg, 'filter');
freqrange               = ft_getopt(cfg, 'freqrange');
analysisTree            = ft_getopt(cfg, 'analysisTree');
showAll                 = ft_getopt(cfg, 'showAll');

if filter & isempty(freqrange)
    error('Please give a frequency range')
end

% gather standards
setStandards()

% find individual subject folders
subjectFolders = dir([PATHS.SUBJECTS filesep sDirString '*']);
subjectFolderNames = {subjectFolders.name};

if ~strcmp(subjects, 'all')
    subjectFolderNames = subjectFolderNames(subjects);
end

for iFolName = 1:length(subjectFolderNames)
    
    try
        load([PATHS.SUBJECTS filesep subjectFolderNames{iFolName} filesep 'Subject.mat'])
    catch
        error('ERROR: no Subject.mat found for %s', subjectFolderNames{iFolName})
    end
    
    cd([subjectdata.PATHS.SUBJECTDIR filesep analysisTree])
    disp(subjectdata.subjectName)
    
    previousDataFile = dir('*cleaned.mat');
    try
        load(previousDataFile.name)
    catch
        error('ERROR: dataStr = %s not found', dataStr)
    end
    
    fprintf('\t %s loaded \n', previousDataFile.name)
    
%     cfg = [];
%     cfg.viewmode = 'vertical';
%     
%     if filter
%         if freqrange(1) ~= inf
%             cfg.preproc.hpfilter        = 'yes';
%             cfg.preproc.hpfreq          = freqrange(1);
%         end
%         if freqrange(2) ~= inf
%             cfg.preproc.lpfilter        = 'yes';
%             cfg.preproc.lpfreq          = freqrange(2);
%         end
%     end
%     
%     fprintf('\t loading data ...')
%     ft_databrowser(cfg, data)
%     fprintf('done')
%     fprintf('press Space to continue...')
%     waituntilspacepress;

    scrollPlotData(data)
end
