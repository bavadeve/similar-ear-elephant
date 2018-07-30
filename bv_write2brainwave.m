function bv_write2brainwave(subjNr)

eval('setOptions')
eval('setPaths')

PATHS.BRAINWAVE = [PATHS.ROOT filesep 'Brainwave'];
if ~exist(PATHS.BRAINWAVE ,'dir')
    mkdir(PATHS.BRAINWAVE)
end

subjectNames = dir([PATHS.SUBJECTS filesep '*' OPTIONS.sDirString '*']);
subjectNames = {subjectNames.name};

for iS = subjNr
    disp(subjectNames{iS})
    [subjectdata, data] = bv_check4data([PATHS.SUBJECTS filesep subjectNames{iS}], 'TRIALLENGTH8');
    
    fprintf('\t saving trialdata to %s ... ', [subjectdata.subjectName '_trialdata.txt'])
    trialDat = [data.trial{:}]';
    
    fid = fopen([PATHS.BRAINWAVE filesep subjectdata.subjectName '_trialdata2.txt'], 'w');
    fprintf(fid, repmat('%s\t', 1, length(data.label)), data.label{:});
    fprintf(fid, [repmat('%12.6f\t', 1, size(trialDat,2)) '\r'], trialDat');
    fclose all;
    
    dlmwrite([PATHS.BRAINWAVE filesep subjectdata.subjectName '_trialdata.txt'],trialDat, '\t');
    fprintf('done! \n')
end