function data = bv_quickloadData(str, filestr)

eval('setOptions')
eval('setPaths')

subject = dir([PATHS.SUBJECTS filesep str '*']);
nSubject = length(subject);

if nSubject ~= 1
    if nSubject == 0
        errorStr = sprintf('Subject with str-input: %s not found', str);
    elseif nSubject > 1
        errorStr = sprintf('Too many subjects found with str-input: %s', str);
    end
    error(errorStr)
end

disp(subject.name)
subjectFolderPath = [PATHS.SUBJECTS filesep subject.name];

[~, data] = bv_check4data(subjectFolderPath, upper(filestr));
