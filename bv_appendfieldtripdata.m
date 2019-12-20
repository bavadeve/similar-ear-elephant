function data = bv_appendfieldtripdata(cfg, dataOld)
% appends data in fieldtrip data structure based on data.sampleinfo, output
% data can be used in concurrence with bv_cutAppendedIntoTrials to cut into
% trials of desired length
%
% can be used with data-input as:
%  [ appendeddata ] = bv_appendfieldtripdata(cfg, data)
%
% or without data-input as:
%  [ appendeddata ] = bv_appendfieldtripdata(cfg)
%
% INPUTS:
% needs the following fields in cfg-structure in the case of no data-input:
%   cfg.currSubject = 'string', subject folder name to analyze
%   cfg.inputStr    = 'string', data to be loaded in, using bv_check4data,
%                       based on subjectdata.PATHS field name (f.e.
%                       'APPENDED')%
%   cfg.saveData    = 'yes/no', determines whether data is saved to disk in
%                       subjectfolder, based on cfg.outputStr with
%                       bv_saveData
%   cfg.outputStr   = 'string', used to save data to unique file, with
%                       unique entry into subjectdata.PATHS
%   cfg.pathsFcn    = path to paths function needed to run
%                       analysis-pipeline (default: './setPaths')
%   cfg.optionsFcn  = path to options function needed to run
%                       analysis-pipeline (default: './setOptions')

%   data: fieldtrip data structure, which should consist of multiple trials
%
% OUTPUTS:
%   appenddata = data appended according to data.sampleinfo
%
% See also, BV_CUTAPPENDEDINTOTRIALS, FT_REDEFINETRIAL
%

%%%% get general options and load in data if necessary %%%%
currSubject = ft_getopt(cfg, 'currSubject');
inputStr    = ft_getopt(cfg, 'inputStr');
outputStr   = ft_getopt(cfg, 'outputStr');
saveData    = ft_getopt(cfg, 'saveData');
pathsFcn    = ft_getopt(cfg, 'pathsFcn', 'setPaths');
optionsFcn  = ft_getopt(cfg, 'optionsFcn', 'setOptions');
cfgIn = cfg;

if nargin < 2
    eval(optionsFcn);
    eval(pathsFcn);
    disp(currSubject)
    subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
    [subjectdata, dataOld] = bv_check4data(subjectFolderPath, inputStr);
else
    saveData = 'no';
end

%%%% calculating own trl for appending data %%%%
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

%%%% redefining trials based on calculated trl %%%%
cfg = [];
cfg.trl = trl;
evalc('data = ft_redefinetrial(cfg, dataOld);');
fprintf('done! \n')

if strcmpi(saveData, 'yes')
    
    subjectdata.analysisOrder = bv_updateAnalysisOrder(subjectdata.analysisOrder, cfgIn);
    bv_updateSubjectSummary([PATHS.SUMMARY filesep 'SubjectSummary.mat'], subjectdata)
    
    bv_saveData(subjectdata, data, outputStr);
end
