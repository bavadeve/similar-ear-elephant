function bv_createNewAnalysis(str, overwrite)

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
    setOptionsExist = bv_createSetOptions(PATHS.CURRANALYSIS);
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
    [preprocessExist, msg] = copyfile(which('preprocessingData_standard'), [PATHS.CURRANALYSIS filesep 'preprocessingData.m']);
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
setPaths
