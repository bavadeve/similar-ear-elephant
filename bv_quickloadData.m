function data = bv_quickloadData(str, filestr)

eval('setOptions')
eval('setPaths')

if isnumeric(str)
    subjects = dir([PATHS.SUBJECTS filesep '*' OPTIONS.sDirString '*']);
    subjectNames = {subjects.name};
    subjectName = subjectNames{str};
else
    
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
    subjectName = subject.name;
    
end

disp(subjectName)
subjectFolderPath = [PATHS.SUBJECTS filesep subjectName];

[~, data] = bv_check4data(subjectFolderPath, upper(filestr));
