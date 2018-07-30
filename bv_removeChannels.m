function removeChannels(cfg)
% remove faulty channels, use before preprocessing! Reject channels in
% ft_rejectvisual GUI
%
% input variables:
%   sDir:       [string] subject directory name
%   sDirString: [string] non-unique part all subject directories (e.g. 'pp')
%
% Copyright (C) 2015-2016, Bauke van der Velde
%
%   removeChannels(sDir, sDirString)

overwrite = ft_getopt(cfg, 'overwrite');

setStandards();

% find subjectfolder names
subjectFolders = dir([PATHS.SUBJECTS filesep sDirString '*']);
subjectFolderNames = {subjectFolders.name};

for iFolName = 1:length(subjectFolderNames)
    % load subject file and go to folder
    try
        load([PATHS.SUBJECTS filesep subjectFolderNames{iFolName} filesep 'Subject.mat'])
    catch
        error('ERROR: no Subject.mat found for %s', subjectFolderNames{iFolName})
    end
    cd(subjectdata.PATHS.SUBJECTDIR)
    disp(subjectdata.subjectName)
    
    doNoAnalysis = isfield(subjectdata, 'removedchannels') && ~overwrite;
    
    if doNoAnalysis
        fprintf('\t removed channels already determined and not overwriting \n')
        continue
    end
    
    % get header, calculate nyquist frequency and based on that create a
    % vector for bandstop filter
    
    bsFreq = [48 52];

    cfg = [];    
    cfg.dataset         = subjectdata.PATHS.DATAFILE;
    cfg.headerfile      = subjectdata.PATHS.HDRFILE;
    cfg.trialfun        = 'trialfun_remChans_10mnd';
    cfg.trigger        = [11 12];
    evalc('cfg = ft_definetrial(cfg);');
    cfg.channel         = {'all'};
    
    % Filtering options and preprocess
    cfg.bsfilter        = 'yes';
    cfg.bsfreq          = bsFreq;
    cfg.hpfilter        = 'yes';
    cfg.hpfreq          = 2;
       
%     % reref options
%     cfg.reref           = 'yes';
%     cfg.refchannel      = {'EEG'};
    
    evalc('data = ft_preprocessing(cfg);');
    
    cfg = [];
    cfg.length = 5;
    cfg.overlap = 0;
    evalc('data = ft_redefinetrial(cfg, data);');
    
    % view data
    cfg = [];
    cfg.viewmode = 'vertical';
    cfg.channel = {'EEG'};
    evalc('ft_databrowser(cfg, data)');
   
    % reject channels in ft_rejectvisual GUI
    cfg = [];
    cfg.method = 'summary';
    cfg.channel = {'EEG', '-A2'};
    evalc('cleanData = ft_rejectvisual(cfg, data);');
    
    close all
    
    % ask operator whether subject need to be removed
    inputStr = sprintf('\t Move subject to removed folder because of bad data? [Y/N]');
    removeSubject = input(inputStr, 's');
    
    if strcmp(removeSubject, 'Y');
        % if bad data, move subject to PATHS.REMOVED and add error message to
        % individual WhyRemoved.txt file and summary removeLog.mat
        if ~exist(PATHS.REMOVED, 'dir')
            mkdir(PATHS.REMOVED)
        end
        
        movefile([subjectdata.PATHS.SUBJECTDIR filesep], PATHS.REMOVED);
        subjectdata.PATHS.SUBJECTDIR   = [PATHS.REMOVED filesep subjectFolderNames{iFolName}];
        errorstr = 'Subject data not good enough, moved to removed directory';
        fprintf('%s: %s', subjectdata.subjectName, errorstr)
        
        fid = fopen([subjectdata.PATHS.SUBJECTDIR filesep 'WhyRemoved.txt'],'w');
        fprintf(fid, errorstr);
        fclose( fid );
        
        if exist([PATHS.REMOVED filesep 'removeLog.mat'], 'file')
            load([PATHS.REMOVED filesep 'removeLog.mat'])
            nrSubjectSoFar = size(removeLog, 1);
        else
            removeLog = {};
            nrSubjectSoFar = 0;
        end
        removeLog{nrSubjectSoFar + 1, 1} = subjectdata.subjectName;
        removeLog{nrSubjectSoFar + 1, 2} = errorstr;
        
        save([PATHS.REMOVED filesep 'removeLog'],'removeLog');
        clear removeLog
    else
        subjectdata.removedchannels = setdiff(data.label, cleanData.label);
        subjectdata.sInfoLastTrial = cleanData.sampleinfo(end, :);
        fprintf(['\t channel(s) to be to removed of subject %s: ' ...
            repmat('%s ', 1, length(subjectdata.removedchannels)) '\n'], subjectdata.subjectName, subjectdata.removedchannels{:})
        save('Subject.mat','subjectdata')
    end
    
    
    
end

cd( PATHS.ROOT )