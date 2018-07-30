function data = bv_cutAppendIntoTrials(cfg, data)

currSubject = ft_getopt(cfg, 'currSubject');
inputStr    = ft_getopt(cfg, 'inputStr');
saveData    = ft_getopt(cfg, 'saveData');
outputStr   = ft_getopt(cfg, 'outputStr');
optionsFcn  = ft_getopt(cfg, 'optionsFcn');
pathsFcn    = ft_getopt(cfg, 'pathsFcn');


if nargin < 2
    
    disp(currSubject)
    
    eval(optionsFcn)
    eval(pathsFcn)
    
    subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
    [subjectdata, data] = bv_check4data(subjectFolderPath, inputStr);
    
    subjectdata.cfgs.(outputStr) = cfg;
    
end