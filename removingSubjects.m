function removingSubjects(cfg, currSubject, reason)

fprintf('\t removing for the following reason: %s\n', reason)

cfg.optionsFcn = ft_getopt(cfg, 'optionsFcn', 'setOptions');
cfg.pathsFcn = ft_getopt(cfg, 'pathsFcn', 'setPaths');

eval(cfg.optionsFcn)
eval(cfg.pathsFcn)

subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
subjectdata = bv_check4data(subjectFolderPath);

lastCalled = dbstack('-completenames',1);

subjectdata.removed = true(1);
if isempty(lastCalled)
    subjectdata.removedDuring = 'commandline';
else
    subjectdata.removedDuring = lastCalled(1).name;
end
subjectdata.removedreason = reason;

bv_saveData(subjectdata)
bv_updateSubjectSummary([PATHS.SUMMARY filesep 'SubjectSummary'], subjectdata)

subjectdata.PATHS.SUBJECTDIR = [PATHS.REMOVED filesep currSubject];

movefile([PATHS.SUBJECTS filesep currSubject], PATHS.REMOVED)
fprintf('\t \t moved to PATHS.REMOVED folders \n')

end