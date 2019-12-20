function data = bv_removeChannels(cfg, data, artefactdef)
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
maxpercbad      = ft_getopt(cfg, 'maxpercbad');
expectedtrials  = ft_getopt(cfg, 'maxtrials');
repairchans     = ft_getopt(cfg, 'repairchans');
overwrite       = ft_getopt(cfg, 'overwrite', 'no');

cfgIn = cfg;

if isempty(lims)
    error('Please give cfg.lims struct as input')
end
if isempty(maxpercbad)
    error('Please set maximum percentage missing per channel in cfg.maxpercbad')
end

if nargin < 2 % data loading
    if isempty(pathsFcn)
        error('please add options function cfg.optionsFcn')
    else
        eval(pathsFcn)
    end
    
    disp(currSubject)
    subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
    [subjectdata] = bv_check4data(subjectFolderPath);
    
    if strcmpi(overwrite, 'no')
        if isfield(subjectdata.PATHS, upper(outputStr))
            if exist(subjectdata.PATHS.(upper(outputStr)), 'file')
                fprintf('\t !!!%s already found, not overwriting ... \n', upper(outputStr))
                data = [];
                return
            end
        end
    end
    
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

fprintf('\t checking for channels to remove ... \n')
% artefact detection
limFields = fieldnames(lims);
for i = 1:length(limFields)
    cField = limFields{i};
    
    out(:,:,i) = artefactdef.(cField).levels > lims.(cField);
    
end

% badchannel calculation
badchans = data.label(((sum(sum(out,3)>0,2) / expectedtrials) * 100 ) > maxpercbad);
subjectdata.channels2remove = badchans;
subjectdata.flatchannels = ...
    data.label(((sum(sum(out(:,:, ...
    contains(limFields, 'flat')),3)>0,2) / expectedtrials) * 100 ) > ...
    maxpercbad);
subjectdata.noisychannels = ...
    data.label(((sum(sum(out(:,:, ...
    not(contains(limFields, 'flat'))),3)>0,2) / expectedtrials) * 100 ) > ...
    maxpercbad);

if not(isempty(subjectdata.channels2remove))
    fprintf(['\t \t bad channels detected: ' repmat('%s,', 1, length(badchans)) '\n'], badchans{:})
    
    % badchannel interpolation
    if strcmpi(repairchans, 'yes') 
        fprintf('\t repairing ... ')
        cfg = [];
        cfg.method          = 'triangulation';
        cfg.template        = 'EEG1010';
        cfg.layout          = 'biosemi32.lay';
        cfg.feedback        = 'no';
        evalc('neighbours = ft_prepare_neighbours(cfg, data);');
        
        cfg = [];
        cfg.missingchannel = subjectdata.channels2remove';
        cfg.method = 'weighted';
        cfg.neighbours = neighbours;
        cfg.layout = 'biosemi32.lay';
        evalc('data = ft_channelrepair(cfg, data);');
        fprintf('done! \n')
    else
        fprintf('\t added to subjectdata struct \n')
    end
end

if strcmpi(saveData, 'yes')
    subjectdata.analysisOrder = bv_updateAnalysisOrder(subjectdata.analysisOrder, cfgIn);
    
    if strcmpi(repairchans, 'yes')
        bv_saveData(subjectdata, data, outputStr);              % save both data and subjectdata to the drive
    else
        bv_saveData(subjectdata);              % save only subjectdata to the drive
    end
    bv_updateSubjectSummary([PATHS.SUMMARY filesep 'SubjectSummary'], subjectdata)
end

