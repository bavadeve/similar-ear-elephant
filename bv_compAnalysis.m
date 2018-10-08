function comp = bv_compAnalysis(cfg, data)

method      = ft_getopt(cfg, 'method', 'runica');
extended    = ft_getopt(cfg, 'extended', 1);
saveData    = ft_getopt(cfg, 'saveData', 0);
outputStr   = ft_getopt(cfg, 'outputStr', 'comp');
inputStr    = ft_getopt(cfg, 'inputStr');
currSubject = ft_getopt(cfg, 'currSubject');
optionsFcn  = ft_getopt(cfg, 'optionsFcn');

if nargin < 2
    disp(currSubject)
    
    eval(optionsFcn)
    
    subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
    [subjectdata, data] = bv_check4data(subjectFolderPath, inputStr);
    
    subjectdata.cfgs.(outputStr) = cfg;
    
end

subjectdata.cfgs.(outputStr) = cfg;

fprintf('\t calculating component analysis ... ')

trialdata = [data.trial{:}];
trialdata(isnan(trialdata)) = [];
cfg = [];
cfg.method              = method;
cfg.(method).extended   = extended;
cfg.(method).pca        = rank(trialdata);
evalc('comp = ft_componentanalysis(cfg, data);');

fprintf('done! \n')

compFilename = [currSubject '_' outputStr '.mat'];

if strcmpi(saveData, 'yes')
    fprintf('\t saving comp file and Subject.mat ... ')
    
    subjectdata.PATHS.COMP = [subjectdata.PATHS.SUBJECTDIR filesep compFilename];
    save(subjectdata.PATHS.COMP, 'comp')
    
    %     analysisOrder = strsplit(subjectdata.analysisOrder, '-');
    %     analysisOrder = [analysisOrder outputStr];
    %     analysisOrder = unique(analysisOrder, 'stable');
    %     subjectdata.analysisOrder = strjoin(analysisOrder, '-');
    
    fprintf('done! \n')
    fprintf('\t saving Subject.mat file ... ')
    save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'], 'subjectdata')
    fprintf('done! \n')
end

