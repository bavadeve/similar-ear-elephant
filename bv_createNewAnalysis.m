function bv_createNewAnalysis()

path2Analyses = [pwd filesep 'Analyses'];
path2RAW = [pwd filesep 'RAW'];
path2PREPROC = [pwd filesep 'PREPROC'];

dateFormat = 'yyyymmdd';
currDate = datestr(now, dateFormat);
path2CurrAnalysis = [path2Analyses filesep currDate];

if ~exist(path2Analyses, 'dir')
    mkdir('Analyses')
end
if ~exist(path2RAW, 'dir')
    mkdir('RAW')
end
if ~exist(path2PREPROC, 'dir')
    mkdir('PREPROC')
end
if ~exist(path2CurrAnalysis, 'dir')
    mkdir(path2CurrAnalysis)
end


