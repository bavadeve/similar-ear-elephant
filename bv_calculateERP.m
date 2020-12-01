function ERPdata = bv_calculateERP(cfg, data)

pathsFcn        = ft_getopt(cfg, 'pathsFcn', 'setPaths');
currSubject     = ft_getopt(cfg, 'currSubject');
overwrite       = ft_getopt(cfg, 'overwrite');
inputStr        = ft_getopt(cfg, 'inputStr');
outputStr       = ft_getopt(cfg, 'outputStr');
saveData        = ft_getopt(cfg, 'saveData');

if nargin < 2 % data preprocessing + loading
    
    if isempty(pathsFcn)
        error('please add options function cfg.pathsFcn')
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
                artefactdef = [];
                return
            end
        end
    end
    
    [~, data] = bv_check4data(subjectFolderPath, inputStr);
end

if isempty(data.trial)
    fprintf('\t no trials found, skipping ... ')
    ERPdata = [];
    return
end

fprintf('\t demeaning and detrending ... ')
cfg = [];
cfg.detrend = 'yes';
cfg.demean = 'yes';
evalc('data = ft_preprocessing(cfg, data);');
fprintf('done! \n')

ERPdata.triggers = unique(data.trialinfo)';
fprintf('\t ERP analysis started ... \n')
for i = 1:length(ERPdata.triggers)
    fprintf('\t   calculating for trigger %1.0f ...', ERPdata.triggers(i))
    cfg = [];
    cfg.trials = find(ismember(data.trialinfo, ERPdata.triggers(i)));
    evalc('tmpERP = ft_timelockanalysis(cfg, data);');
    fprintf('done! \n')
    
    ERPdata.nTrls(i) = length(cfg.trials);
    
    fprintf('\t\tbaseline correction ... ')
    cfg = [];
    cfg.channel = 'all';
    cfg.baseline = [-0.2 0];
    evalc('tmpERP = ft_timelockbaseline(cfg, tmpERP);');
    fprintf('done! \n')
    
    ERPdata.time = tmpERP.time;
    ERPdata.label = tmpERP.label;
    ERPdata.avgs(:,:,i) = tmpERP.avg;
end
ERPdata.dimord = 'chan_time_trig';

% **** saving data
if strcmpi(saveData, 'yes')
       
    bv_saveData(subjectdata, ERPdata, outputStr);              % save both data and subjectdata to the drive
    bv_updateSubjectSummary([PATHS.SUMMARY filesep 'SubjectSummary'], subjectdata)
    
end
