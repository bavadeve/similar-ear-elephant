function bv_createNewAnalysis(str, overwrite)
% creates folder structure for a new analysis in the YOUth-EEG-pipeline
%
% use as:
%   bv_createNewAnalysis(label, overwrite)
%
% with:
%       label         = {string}, label to add to foldername
%       overwrite     = bool, set to true if earlier analysis with similar
%                           folder name should be overwritten
%
% function will create the following folder structure within the current
% working directory
% |_ RAW                        (folder to add raw EEG files to)
% |_ PREPROC                    (folder in which preprocesssed EEG files will be
%                                   placed)
% |_ files                      (folder for extra files, f.e. logs and
%                                   questionnaires)
% |_ Analyses                   (home folder of all analyses)
%   |_ [date '_' label]         (current new analysis homefolder)
%       |_ config               (folder where configuration files are automatically
%                                   saved, saved as PATHS.CONFIG)
%       |_ figures              (folder where figures are automatically saved, 
%                                   saved as PATHS.FIGURES)
%       |_ results              (folder where results are automatically saved,
%                                   saved as PATHS.RESULTS)
%       |_ subfunctions         (folder for functions specifically made for the
%                                   current analysis, saved as PATHS.SUBFUNCTIONS)
%       |_ Subjects             (folder where subject folders will be created and
%                                   saved)
%           |_ removed          (folder where removed subjects will be
%                                   automatically moved to)
%       |_ summary              (folder for summary files)
%       -> log.txt              (text file which automatically logs the
%                                   inputs of the analysis)
%       -> preprocessingData.m  (script for all preprocessing steps 
%       -> setOptions.m         (all options to set (and change) for the
%                                   current analysis
%       -> setPaths.m           (all paths necessary for running the
%                                   analysis, please check if paths are
%                                   correct (especially the fieldtrip
%                                   path))
%
% Bauke van der Velde, Utrecht Universitym, 2019-2022
%                       
% see also bv_createSetPaths setOptions_default bv_createNewLog

if nargin < 2
    overwrite = 0;
end

if ~isempty(str)
    str = ['_' str];
end

PATHS.HOME = pwd;
PATHS.ANALYSES = [PATHS.HOME filesep 'Analyses'];
PATHS.RAW = [PATHS.HOME filesep 'RAW'];
PATHS.PREPROC = [PATHS.HOME filesep 'PREPROC'];

dateFormat = 'yyyymmdd';
currDate = datestr(now, dateFormat);
PATHS.CURRANALYSIS = [PATHS.ANALYSES filesep currDate str];

fprintf('\ncreating folders: \n');
[~, msg] = mkdir(PATHS.ANALYSES);
fprintf('\tanalysis folder: ')
if ~isempty(msg)
    fprintf([msg '\n'])
else
    fprintf('created \n');
end

[~, msg] = mkdir(PATHS.RAW);
fprintf('\traw folder: ')
if ~isempty(msg)
    fprintf([msg '\n'])
else
    fprintf('created \n');
end

[~, msg] = mkdir(PATHS.PREPROC);
fprintf('\tpreproc folder: ')
if ~isempty(msg)
    fprintf([msg '\n'])
else
    fprintf('created \n');
end

[~, msg] = mkdir(PATHS.CURRANALYSIS);
fprintf('\tcurranalysis folder: ')
if ~isempty(msg)
    fprintf([msg '\n'])
else
    fprintf('created \n');
end

fprintf('creating scripts: \n')
fprintf('\t')
if ~overwrite && exist([PATHS.CURRANALYSIS filesep 'setPaths.m'], 'file')
    setPathExist = true(1);
    fprintf('setPaths.m already exists, not overwriting \n')
else
    setPathExist = bv_createSetPaths(PATHS.CURRANALYSIS, PATHS.HOME);
    if setPathExist
        fprintf('setPaths.m created \n')
    else
        fprintf('setPaths.m creation failed, please check  \n')
    end
end

fprintf('\t')
if ~overwrite && exist([PATHS.CURRANALYSIS filesep 'setOptions.m'], 'file')
    setOptionsExist = true(1);
    fprintf('setOptions.m already exists, not overwriting \n')
else
    setOptionsExist = copyfile(which('setOptions_default'), [PATHS.CURRANALYSIS filesep 'setOptions.m']);
    if setOptionsExist
        fprintf('setOptions.m created \n')
    else
        fprintf('setOptions.m creation failed, please check \n')
    end
end

fprintf('\t')
if ~overwrite && exist([PATHS.CURRANALYSIS filesep 'preprocessingData.m'], 'file')
    preprocessExist = true(1);
    fprintf('preprocessingData.m already exists, not overwriting \n')
else
    parprocess = questdlg('Will you use parallel processing?');
    
    if strcmpi(parprocess, 'yes')
        [preprocessExist, msg] = copyfile(which('preprocessingData_standard_parfor'), [PATHS.CURRANALYSIS filesep 'preprocessingData.m']);
    else
        [preprocessExist, msg] = copyfile(which('preprocessingData_standard'), [PATHS.CURRANALYSIS filesep 'preprocessingData.m']);
    end
    if  preprocessExist
        fprintf('preprocessingData.m created \n')
    else
        fprintf('preprocessingData.m not created with following warning: \n\t\t %s\n', msg)
    end
end

fprintf('create log: \n')
if ~overwrite && exist([PATHS.CURRANALYSIS filesep 'log.txt'], 'file')
    logExist = true(1);
    fprintf('log.txt already exists, not overwriting \n')
else
    logExist = true(1);
    bv_createNewLog([PATHS.CURRANALYSIS filesep 'log.txt'])
end

fprintf('\n')
if setPathExist && setOptionsExist && preprocessExist && logExist
    fprintf('function finished with no problems !\n')
else
    fprintf('!!function finished with (several) warnings, please check \n')
end

cd(PATHS.CURRANALYSIS)
eval('setPaths')
