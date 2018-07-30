function data = bv_averageReref(cfg, data)

currSubject = ft_getopt(cfg, 'currSubject');
inputStr    = ft_getopt(cfg, 'inputStr');
saveData    = ft_getopt(cfg, 'saveData');
outputStr   = ft_getopt(cfg, 'outputStr');
optionsFcn  = ft_getopt(cfg, 'optionsFcn');
refElectrode = ft_getopt(cfg, 'refElectrode');


if nargin < 2
    disp(currSubject)
    
    eval(optionsFcn)
    
    subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
    [subjectdata, data] = bv_check4data(subjectFolderPath, inputStr);
    
    subjectdata.cfgs.(outputStr) = cfg;
    
end

fprintf('\t rereferencing data ...')

cfg = [];
cfg.reref = 'yes';
cfg.refchannel = refElectrode;
evalc('data = ft_preprocessing(cfg,data);');

fprintf('done! \n')

if strcmpi(saveData, 'yes')
    outputFilename = [ currSubject '_' outputStr '.mat'];
    subjectdata.PATHS.REREF = [subjectdata.PATHS.SUBJECTDIR filesep outputFilename];
    
    if ~isfield(subjectdata, 'analysisOrder')
        subjectdata.analysisOrder = lower(inputStr);
    end
    
    analysisOrder = strsplit(subjectdata.analysisOrder, '-');
    analysisOrder = [analysisOrder outputStr];
    analysisOrder = unique(analysisOrder, 'stable');
    subjectdata.analysisOrder = strjoin(analysisOrder, '-');
    
    fprintf('\t saving preproc data to %s ... ', outputFilename)
    save([subjectdata.PATHS.REREF], 'data')
    fprintf('done! \n')
    
    fprintf('\t saving Subject.mat file ... ' )
    save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'], 'subjectdata')
    fprintf('done! \n')
end
