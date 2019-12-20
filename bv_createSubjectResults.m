function subjectresults = bv_createSubjectResults(inputStr, keepstruct)

eval('setPaths')
eval('setOptions')

% if exist([PATHS.SUMMARY filesep 'SubjectSummary.mat'], 'file')
%     load([PATHS.SUMMARY filesep 'SubjectSummary'], 'subjectdatasummary')
% else
    fprintf('\t SubjectSummary.mat not found, creating one based on Subject.mat files \n')
    subjectdirflags1 = dir([PATHS.SUBJECTS filesep '*' OPTIONS.sDirString '*']);
    subjectdirflags2 = dir([PATHS.REMOVED filesep '*' OPTIONS.sDirString '*']);
    subjectdirflags = [subjectdirflags1; subjectdirflags2];

    for i = 1:length(subjectdirflags)
        if i ==1
            subjectdatasummary = bv_check4data([subjectdirflags(1).folder filesep subjectdirflags(1).name]);
        else
            subjectdata = bv_check4data([subjectdirflags(i).folder filesep subjectdirflags(i).name]);
            subjectdatafields = fields(subjectdata);
            subjectdatasummaryfields = fields(subjectdatasummary);
            missingFieldsSummary = subjectdatafields(find(not(ismember(subjectdatafields, ...
                subjectdatasummaryfields))));
            
            if ~isempty(missingFieldsSummary)
                for j = missingFieldsSummary'
                    switch class(subjectdata.(j{:}))
                        case 'struct'
                            [subjectdatasummary(1:end).(j{:})] = deal(struct);
                        case 'double'
                            [subjectdatasummary(1:end).(j{:})] = deal(NaN);
                        case 'char'
                            [subjectdatasummary(1:end).(j{:})] = deal('');
                        case 'cell'
                            [subjectdatasummary(1:end).(j{:})] = deal(cell(0));
                    end
                end
            end
            
            missingFieldsSubjectdata = subjectdatasummaryfields(find(not(ismember(subjectdatasummaryfields, ...
                subjectdatafields))));
            
            if ~isempty(missingFieldsSubjectdata)
                for j = missingFieldsSubjectdata'
                    switch class(subjectdatasummary(1).(j{:}))
                        case 'struct'
                            subjectdata.(j{:}) = struct;
                        case 'double'
                            subjectdata.(j{:}) = NaN;
                        case 'char'
                            subjectdata.(j{:}) = '';
                        case 'cell'
                            subjectdata.(j{:}) = cell(0);
                    end
                end
            end
            
            subjectdatasummary(i) = subjectdata;
            
        end
    end
% end

if nargin > 0
    counter = 0;
    for i = 1:length(subjectdatasummary)
        if not(subjectdatasummary(i).removed)
            counter = counter + 1;
            subjectresultstmp = subjectdatasummary(i);
            try
                resultsStruct = ...
                    bv_quickloadData(subjectdatasummary(i).subjectName, inputStr);
            catch
                fprintf('\t inputStr not found, skipping \n')
                continue
            end
            if keepstruct
                subjectresultstmp.(inputStr) = resultsStruct;
                
            else
                fnames = fieldnames(resultsStruct);
                for j = 1:length(fnames)
                    subjectresultstmp.(fnames{j}) = resultsStruct.(fnames{j});
                end
                if counter ~= 1
                    fnamesSummary = fieldnames(subjectresults);
                    fnamesTmp = fieldnames(subjectresultstmp);
                    extraFields = fnamesTmp(find(not(ismember(fnamesTmp, fnamesSummary))));
                    
                    for j = 1:length(extraFields)
                        subjectresultstmp = rmfield(subjectresultstmp, extraFields{j});
                    end
                end
            end
            subjectresults(counter) = subjectresultstmp;
        end
    end
else
    subjectresults = subjectdatasummary;
end
