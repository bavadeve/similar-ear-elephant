function [data, finished] = bv_cutAppendedIntoTrials(cfg, dataOld)

currSubject = ft_getopt(cfg, 'currSubject');
inputStr    = ft_getopt(cfg, 'inputStr');
outputStr   = ft_getopt(cfg, 'outputStr');
saveData    = ft_getopt(cfg, 'saveData');
triallength = ft_getopt(cfg, 'triallength');

if isempty(triallength)
    error('no config struct does not contain triallength')
end

if nargin < 2
    disp(currSubject)
    
    eval('setOptions');
    eval('setPaths');
    
    subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
    [subjectdata, dataOld] = bv_check4data(subjectFolderPath, inputStr);
end

if ~isfield(dataOld, 'contSecs')
    dataOld.contSecs = (diff(dataOld.sampleinfo') + 1) ./ dataOld.fsample;
end

trialparts2use = find(dataOld.contSecs > triallength);

if isempty(trialparts2use)
    fprintf('\t \t no trials found, skipping ... \n')
    data = [];
    finished = 0;
    return;
end

sampleinfo = [];
trialinfo = [];
for i = 1:length(trialparts2use)
    trl = trialparts2use(i);
    nTrls = floor(dataOld.contSecs(trl) / triallength);
    
    for j = 1:nTrls
        currsampleinfoStart = (dataOld.sampleinfo(trl,1) + triallength*dataOld.fsample*(j-1));
        currsampleinfoEnd = dataOld.sampleinfo(trl,1) + triallength*dataOld.fsample*(j) - 1;
        currsampleinfo = [currsampleinfoStart currsampleinfoEnd];
        
        sampleinfo = cat(1, sampleinfo, currsampleinfo);
        trialinfo = cat(1, trialinfo, dataOld.trialinfo(trl));
        
    end
end

fprintf('\t %1.0f trials found \n', length(trialinfo))

trl = [sampleinfo zeros(size(sampleinfo,1),1) trialinfo];

fprintf('\t redefining triallength to %1.0fs ... ', triallength)
cfg = [];
cfg.trl = trl;
evalc('data = ft_redefinetrial(cfg, dataOld);');
fprintf('done! \n')

if strcmpi(saveData, 'yes')
    
    bv_saveData(subjectdata, data, outputStr)
    
end
finished = 1;

