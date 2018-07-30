function removingSubjects(cfg, currSubject, reason)

fprintf('\t removing for the following reason: %s\n', reason)

cfg.optionsFcn = ft_getopt(cfg, 'optionsFcn', 'setOptions');
cfg.pathsFcn = ft_getopt(cfg, 'pathsFcn', 'setPaths');

eval(cfg.optionsFcn)
eval(cfg.pathsFcn)

subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
subjectdata = bv_check4data(subjectFolderPath);

subjectdata.removed.bool = 'yes';
subjectdata.removed.reason = reason;

bv_saveData(subjectdata)

movefile([PATHS.SUBJECTS filesep currSubject], PATHS.REMOVED)
fprintf('\t \t moved to PATHS.REMOVED folders \n')

end