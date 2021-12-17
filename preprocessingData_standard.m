%% SET THE SUBJECT RANGE BEFORE RUNNING
startSubject =  1;
endSubject = 'end';

clear PATHS
global PATHS

eval('setPaths')
eval('setOptions')


subjectFolders = dir([PATHS.SUBJECTS filesep '*' OPTIONS.sDirString '*']);
subjectFolderNames = {subjectFolders.name};

if ischar(startSubject)
    startSubject = find(~cellfun(@isempty, strfind(subjectFolderNames, startSubject)));
end
if ischar(endSubject)
    if strcmp(endSubject, 'end')
        endSubject = length(subjectFolderNames);
    else
        endSubject = find(~cellfun(@isempty, strfind(subjectFolderNames, endSubject)));
    end
end

save([PATHS.CONFIG filesep 'OptionsAndPaths.mat'], 'OPTIONS', 'PATHS')

%% PREPROCESSING AND RESAMPLING
clear OPTIONS
eval('setOptions')

cfg             = OPTIONS.PREPROC;

% save options to preproc folder
if strcmpi(cfg.saveData, 'yes')
    preproc_cfg = cfg;
    preproc_cfg.date = clock;
    preproc_cfg.subjects = subjectFolderNames(startSubject:endSubject);
    
    save([PATHS.PREPROC filesep 'configfile.mat'], 'preproc_cfg')
end

counter = 0;
for iSubjects = startSubject:endSubject
    counter = counter + 1;
    fprintf('%1.0f/%1.0f\n', counter, length(startSubject:endSubject))    currSubject = subjectFolderNames{iSubjects};
    
    cfg.currSubject = currSubject;
    
    data = bv_preprocResample(cfg);
    
end


%% COMPONENT CALCULATION
eval('setOptions')
counter = 0;
for iSubjects = startSubject:endSubject
    counter = counter + 1;
    fprintf('%1.0f/%1.0f\n', counter, length(startSubject:endSubject))    currSubject = subjectFolderNames{iSubjects};
    
    cfg             = OPTIONS.COMP;
    cfg.currSubject = currSubject;
    
    comp = bv_compAnalysis(cfg);
end

%% COMPONENT REMOVAL
eval('setOptions')
counter = 0;
for iSubjects = startSubject:endSubject
    counter = counter + 1;
    fprintf('%1.0f/%1.0f\n', counter, length(startSubject:endSubject))    currSubject = subjectFolderNames{iSubjects};
    
    cfg             = OPTIONS.COMPREMOVED;
    cfg.currSubject = currSubject;
    
    data = bv_removeComps(cfg);
end

%% REMOVING POOR CHANNELS
eval('setOptions')
counter = 0;
for iSubjects = startSubject:endSubject
    counter = counter + 1;
    fprintf('%1.0f/%1.0f\n', counter, length(startSubject:endSubject))    currSubject = subjectFolderNames{iSubjects};
    
    cfg             = OPTIONS.RMCHANNELS;
    cfg.currSubject = currSubject;
    
    data = bv_artefactRejection(cfg);
end


%% REREFERENCING
eval('setOptions')
counter = 0;
for iSubjects = startSubject:endSubject
    counter = counter + 1;
    fprintf('%1.0f/%1.0f\n', counter, length(startSubject:endSubject))    currSubject = subjectFolderNames{iSubjects};
    
    cfg             = OPTIONS.REREF;
    cfg.currSubject = currSubject;
    
    data = bv_averageReref(cfg);
end


%% REMOVING POOR TRIALS
eval('setOptions')
counter = 0;
for iSubjects = startSubject:endSubject
    counter = counter + 1;
    fprintf('%1.0f/%1.0f\n', counter, length(startSubject:endSubject))    currSubject = subjectFolderNames{iSubjects};
    
    cfg                 = OPTIONS.CLEANED;
    cfg.currSubject     = currSubject;
    
    data = bv_artefactRejection(cfg);
end


%% APPEND BASED ON SAMPLEINFO
eval('setOptions')
counter = 0;
for iSubjects = startSubject:endSubject
    counter = counter + 1;
    fprintf('%1.0f/%1.0f\n', counter, length(startSubject:endSubject))    currSubject = subjectFolderNames{iSubjects};
    
    cfg.currSubject = currSubject;
    cfg.inputStr    = 'CLEANED';
    cfg.outputStr   = 'appended';
    cfg.saveData    = 'yes';
    
    data = bv_appendCleanedData(cfg);
end


%% CUT APPENDED DATA INTO TRIALS
eval('setOptions')
counter = 0;
for iSubjects = startSubject:endSubject
    counter = counter + 1;
    fprintf('%1.0f/%1.0f\n', counter, length(startSubject:endSubject))    currSubject = subjectFolderNames{iSubjects};
    
    cfg = OPTIONS.DATACUT;
    cfg.currSubject = currSubject;
    
    data = bv_cutAppendedIntoTrials(cfg);
end

