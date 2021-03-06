function subjectresults = bv_createSubjectResults(inputStr, keepstruct)

eval('setPaths')
eval('setOptions')

fprintf('Creating subject results \n')
fprintf('\t Creating subjectsummary ... ')
subjectdirflags = dir([PATHS.SUBJECTS filesep '*' OPTIONS.sDirString '*']);

for i = 1:length(subjectdirflags)
    lng = printPercDone(length(subjectdirflags), i);
    if i ==1
        evalc('subjectdatasummary = bv_check4data([subjectdirflags(1).folder filesep subjectdirflags(1).name]);');
    else
        evalc('subjectdata = bv_check4data([subjectdirflags(i).folder filesep subjectdirflags(i).name]);');
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
    fprintf(repmat('\b', 1, lng))
end
fprintf('done! \n')
% end

if nargin > 0
    counter = 0;
    fprintf('\t loading results into subjectsummary ... ')
    for i = 1:length(subjectdatasummary)
        lng = printPercDone(length(subjectdatasummary), i);
%         if not(subjectdatasummary(i).removed)
            counter = counter + 1;
            subjectresultstmp = subjectdatasummary(i);
            try
                evalc('resultsStruct = bv_quickloadData(subjectdatasummary(i).subjectName, inputStr);');
            catch
%                 fprintf('\t inputStr not found, skipping \n')
                fprintf(repmat('\b', 1, lng))
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
                    extraFieldsTmp = fnamesTmp(find(not(ismember(fnamesTmp, fnamesSummary))));
                    extraFieldsSummary = fnamesSummary(find(not(ismember(fnamesSummary, fnamesTmp))));
                    
                    for j = 1:length(extraFieldsTmp)
                        subjectresultstmp = rmfield(subjectresultstmp, extraFieldsTmp{j});
                    end
                    for j = 1:length(extraFieldsSummary)
                        subjectresults = rmfield(subjectresults, extraFieldsSummary{j});
                    end
                end
            end
            subjectresults(counter) = subjectresultstmp;
%         end
        fprintf(repmat('\b', 1, lng))
    end
    fprintf('done! \n')
else
    subjectresults = subjectdatasummary;
end
