function bv_saveData(subjectdata, data, outputStr)

global PATHS

if nargin > 1
    filename = [subjectdata.subjectName '_' outputStr '.mat'];
    
    if strcmpi(outputStr, 'PREPROC')
        filePath = [PATHS.PREPROC filesep filename];
    else
        filePath = [subjectdata.PATHS.SUBJECTDIR filesep filename];
    end
    subjectdata.PATHS.(upper(outputStr)) = filePath;
    
    fprintf('\t saving %s ... ', filePath)
    save(filePath, 'data')
    fprintf('done! \n')
    
end

fprintf('\t saving Subject.mat ... ')
save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'], 'subjectdata')
fprintf('done! \n');