function data = bv_appendCleanedData(cfg)

currSubject = ft_getopt(cfg, 'currSubject');
inputStr    = ft_getopt(cfg, 'inputStr');
outputStr   = ft_getopt(cfg, 'outputStr');
saveData    = ft_getopt(cfg, 'saveData');

disp(currSubject)

eval('setOptions');
eval('setPaths');

subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
[subjectdata, dataOld] = bv_check4data(subjectFolderPath, inputStr);

fprintf('\t appending cleaned data based on data.sampleinfo ... ')
fsample = dataOld.fsample;

triallength = size(dataOld.trial{1},2) ./ 512;

startTrial = dataOld.sampleinfo(:,1);
endTrial = dataOld.sampleinfo(:,2);
trialinfo = dataOld.trialinfo;

tmptrl(:,1) = startTrial(find([1; diff(startTrial) ~= length(dataOld.trial{1})]));
tmptrl(:,2) = endTrial(find([diff(startTrial) ~= length(dataOld.trial{1}); 1]));

tmptrialinfo = dataOld.trialinfo(ismember(dataOld.sampleinfo(:,1), tmptrl(:,1)));

trl = [tmptrl zeros(length(tmptrialinfo),1) tmptrialinfo];

contSecs = (diff(tmptrl, [], 2) + 1) / fsample;
% 
cfg = [];
cfg.trl = trl;
evalc('data = ft_redefinetrial(cfg, dataOld);');
fprintf('done! \n')

data.contSecs = contSecs;

if strcmpi(saveData, 'yes')
    
    bv_saveData(subjectdata, data, outputStr)
    
end

    

