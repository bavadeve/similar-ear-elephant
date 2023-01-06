function subjectresults = bv_createSubjectResults(inputStr, keepstruct)

eval('setPaths')
eval('setOptions')

fprintf('Creating subject results \n')
fprintf('\t Creating subjectsummary ... ')
subjectdirflags = dir([PATHS.SUBJECTS filesep '*' OPTIONS.sDirString '*']);
subjectrmflags = dir([PATHS.REMOVED filesep '*' OPTIONS.sDirString '*']);

subjectdirflags = [subjectdirflags; subjectrmflags];

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
subjectdatasummary = struct2table(subjectdatasummary);

if nargin > 0
    fprintf('\t loading results into subjectsummary ... ')
    startIndx = 1;
    while 1
        for i = startIndx
            subjectresultstmp = subjectdatasummary(i,:);
            
            evalc('[resultsStruct, succeed] = bv_quickloadData(subjectdatasummary.subjectName{i}, inputStr);');
            
            if ~succeed
                fprintf(repmat('\b', 1, lng))
                startIndx = startIndx + 1;
                break
            end
            if keepstruct
                subjectresultstmp.(inputStr) = resultsStruct;
            else
                fnames = fieldnames(resultsStruct);
                for j = 1:length(fnames)
                    switch class(resultsStruct.(fnames{j}))
                        case 'double'
                            if length(resultsStruct.(fnames{j}))==1
                                subjectresultstmp.(fnames{j})(1) = resultsStruct.(fnames{j});
                            else
                                subjectresultstmp.(fnames{j}){1} = resultsStruct.(fnames{j});
                            end
                        otherwise
                            subjectresultstmp.(fnames{j}){1} = resultsStruct.(fnames{j});
                    end
                end
            end
        end
        
        if exist('subjectresultstmp', 'var')
            break
        end
        
    end
    vartypes = varfun(@class,subjectresultstmp,'OutputFormat','cell');
    [subjectresultstmp(1,ismember(vartypes, 'cell'))] = {''};
    subjectresultstmp{1,ismember(vartypes, 'double')} = NaN;
    [subjectresultstmp{1,ismember(vartypes, 'logical')}] = false;
    
    
    updateWaitbar = waitbarParfor(height(subjectdatasummary), 'Adding to subjectsummary ...');
    parfor i = 1:height(subjectdatasummary)
%         if subjectdatasummary(i,:).removed
%             continue
%         end
        subjectresults(i,:) = add2subjectresults(subjectdatasummary(i,:), subjectresultstmp, inputStr, keepstruct);
        updateWaitbar();
    end
    fprintf('done! \n')
    subjectresults(ismissing(subjectresults.pseudo),:) =[];
else
    subjectresults = subjectdatasummary;
end

% HELPER FUNCTIONS
function subjectresults = add2subjectresults(subjectdatasummary, subjectresults, inputStr, keepstruct)
subjectresultstmp = subjectdatasummary;

if subjectdatasummary.removed
    return
end

evalc('[resultsStruct, succeed] = bv_quickloadData(subjectdatasummary.subjectName, inputStr);');

if ~(succeed)
    % fprintf('\t inputStr not found, skipping \n')
    return
end
if keepstruct
    subjectresultstmp.(inputStr) = resultsStruct;
else
    fnames = fieldnames(resultsStruct);
    for j = 1:length(fnames)
        subjectresultstmp.(fnames{j}){1} = resultsStruct.(fnames{j});
    end
    fnamesSummary = fieldnames(subjectresults);
    fnamesTmp = fieldnames(subjectresultstmp);
    extraFieldsTmp = fnamesTmp(find(not(ismember(fnamesTmp, fnamesSummary))));
    extraFieldsSummary = fnamesSummary(find(not(ismember(fnamesSummary, fnamesTmp))));
    
    for j = 1:length(extraFieldsTmp)
        if isstruct(subjectresultstmp)
            subjectresultstmp = rmfield(subjectresultstmp, extraFieldsTmp{j});
        elseif istable(subjectresultstmp)
            subjectresultstmp(:, ismember(subjectresultstmp.Properties.VariableNames, extraFieldsTmp{j})) = [];
        end
        
    end
    for j = 1:length(extraFieldsSummary)
        if isstruct(subjectresultstmp)
            subjectresults = rmfield(subjectresults, extraFieldsSummary{j});
        elseif istable(subjectresultstmp)
            subjectresults(:, ismember(subjectresults.Properties.VariableNames, extraFieldsTmp{j})) = [];
        end
        
    end
    
end
subjectresults = subjectresultstmp;
