%% SET THE SUBJECT RANGE BEFORE RUNNING
startSubject = 1;
endSubject = 'end';

clear PATHS
global PATHS

eval('setPaths')
eval('setOptions')


subjectFolders = dir([PATHS.SUBJECTS filesep '*' OPTIONS.sDirString '*']);
subjectFolderNames = {subjectFolders.name};

if ischar(startSubject)
    startSubject = find(contains(subjectFolderNames, startSubject));
end
if ischar(endSubject)
    if strcmp(endSubject, 'end')
        endSubject = length(subjectFolderNames);
    else
        endSubject = find(contains(subjectFolderNames, endSubject));
    end
end

save([PATHS.CONFIG filesep 'OptionsAndPaths.mat'], 'OPTIONS', 'PATHS')

%% PREPROCESSING AND RESAMPLING COHERENCE
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

updateWaitbar = waitbarParfor(length(startSubject:endSubject), "Preprocessing...");
for iSubjects = startSubject:endSubject
    
        currSubject = subjectFolderNames{iSubjects};
        cfg             = OPTIONS.PREPROC;
        cfg.currSubject = currSubject;
        cfg.quiet       = 'no';
        data = bv_preprocResample(cfg);
        updateWaitbar(); 
end


%% CALCULATE ARTEFACTS IN PREPROC DATA
setupSubjects
updateWaitbar = waitbarParfor(length(startSubject:endSubject), "Artefact detection (preprocessed data)...");
eval('setOptions')
parfor iSubjects = startSubject:endSubject
    currSubject = subjectFolderNames{iSubjects};
    
    cfg             = OPTIONS.ARTFCTPREPROC;
    cfg.quiet       = 'yes';
    cfg.currSubject = currSubject;
    
    artefactdef = bv_createArtefactStruct(cfg);
    updateWaitbar(); 
end


%% SET CHANNELS TO REMOVE
setupSubjects
updateWaitbar = waitbarParfor(length(startSubject:endSubject), "Find channels to remove...");
eval('setOptions')
parfor iSubjects = startSubject:endSubject
    currSubject = subjectFolderNames{iSubjects};
    
    cfg             = OPTIONS.RMCHANNELS;
    cfg.currSubject = currSubject;
    cfg.quiet       = 'yes';
    cfg.overwrite = 'yes';
    
    data = bv_removeChannels(cfg);
    updateWaitbar();
    
end

%% PREPROCESSING AGAIN WITH REREF AND WITHOUT REMOVED CHANNELS
eval('setOptions')
setupSubjects
updateWaitbar = waitbarParfor(length(startSubject:endSubject), "Preprocess (without removed channels)...");
parfor iSubjects = startSubject:endSubject
    currSubject = subjectFolderNames{iSubjects};
    
    cfg             = OPTIONS.REREF;
    cfg.currSubject = currSubject;
    cfg.quiet = 'yes';
    
    data = bv_preprocResample(cfg);
    updateWaitbar();

end

%% CALCULATE ARTEFACTS IN RMCHANNELS DATA
eval('setOptions')
setupSubjects
updateWaitbar = waitbarParfor(length(startSubject:endSubject), "Artefact detection (clean preprocessed data)...");

for iSubjects = startSubject:endSubject
    
    currSubject = subjectFolderNames{iSubjects};
    
    cfg             = OPTIONS.ARTFCTRMCHANNELS;
    cfg.currSubject = currSubject;
    cfg.quiet = 'yes';
    artefactdef = bv_createArtefactStruct(cfg);
    updateWaitbar();
    
end

%% CALCULATE DATALOSS BASED ON ARTFCTAFTER
eval('setOptions')
setupSubjects
updateWaitbar = waitbarParfor(length(startSubject:endSubject), "Remove poor trials...");

for iSubjects = startSubject:endSubject

    currSubject = subjectFolderNames{iSubjects};
    
    cfg             = OPTIONS.CLEANED;
    cfg.currSubject = currSubject;
    cfg.quiet       = 'yes';
    
    data = bv_cleanData(cfg);
    updateWaitbar();
end

%% APPEND DATA
eval('setOptions')
setupSubjects
updateWaitbar = waitbarParfor(length(startSubject:endSubject), "Append data...");

parfor iSubjects = startSubject:endSubject

    cfg = OPTIONS.APPENDED;
    cfg.currSubject = subjectFolderNames{iSubjects};
    cfg.quiet = 'yes';
    
    data = bv_appendfieldtripdata(cfg);
    updateWaitbar();
    
end