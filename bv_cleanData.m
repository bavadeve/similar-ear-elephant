function data = bv_cleanData(cfg, data, artefactdef)
% remove faulty channels, based on given limits in config-var
%
% input variables:
%   cfg:        [struct] with the following fields
%
%
%   sDirString: [string] non-unique part all subject directories (e.g. 'pp')
%
% Copyright (C) 2015-2016, Bauke van der Velde
%
%   removeChannels(sDir, sDirString)

lims            = ft_getopt(cfg, 'lims');
pathsFcn        = ft_getopt(cfg, 'pathsFcn');
currSubject     = ft_getopt(cfg, 'currSubject');
inputStr        = ft_getopt(cfg, 'inputStr');
outputStr       = ft_getopt(cfg, 'outputStr');
artfctdefStr    = ft_getopt(cfg, 'artfctdefStr');
saveData        = ft_getopt(cfg, 'saveData');
expectedtrials  = ft_getopt(cfg, 'expectedtrials');
cleanDatafile   = ft_getopt(cfg, 'cleanDatafile');
dataLossLabel   = ft_getopt(cfg, 'dataLossLabel', 'dataLoss');

cfgIn = cfg;

if isempty(lims)
    error('Please give cfg.lims struct as input')
end

if nargin < 2 % data loading
    if isempty(pathsFcn)
        error('please add options function cfg.optionsFcn')
    else
        eval(pathsFcn)
    end
    
    subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
    [subjectdata, data, artefactdef] = bv_check4data(subjectFolderPath, inputStr, artfctdefStr);
    
    subjectdata.cfgs.(outputStr) = cfg;
else
    subjectdata = struct;
    repairchans = 'yes';
    saveData = 'no';
end

if isempty(expectedtrials)
    expectedtrials = size(artefactdef.sampleinfo,1);
end

% artefact detection
limFields = fieldnames(lims);
for i = 1:length(limFields)
    cField = limFields{i};
    
    out(:,:,i) = artefactdef.(cField).levels > lims.(cField);
    
end

% dataloss calculation
nBadTrials = sum(sum(sum(out,3)>0) > 0);
nGoodTrials = size(out,2) - nBadTrials;
subjectdata.(dataLossLabel) = (1 - min([nGoodTrials, expectedtrials]) / expectedtrials) * 100;

if strcmpi(cleanDatafile, 'yes')
    goodTrialIndx = find(sum(sum(out,3)>0) == 0);
    
    cfg = [];
    cfg.trl = [artefactdef.sampleinfo(goodTrialIndx,:), zeros(length(goodTrialIndx),1)];
    data = ft_redefinetrial(cfg, data);
end

if strcmpi(saveData, 'yes')
    subjectdata.analysisOrder = bv_updateAnalysisOrder(subjectdata.analysisOrder, cfgIn);
    
    if strcmpi(cleanDatafile, 'yes')
        bv_saveData(subjectdata, data, outputStr);              % save both data and subjectdata to the drive
    else
        bv_saveData(subjectdata);              % save only subjectdata to the drive
    end
    bv_updateSubjectSummary([PATHS.SUMMARY filesep 'SubjectSummary'], subjectdata)
end




