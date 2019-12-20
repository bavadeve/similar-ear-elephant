function subjectdatasummary = bv_addLog2Subjectsummary(subjectdatasummary)

eval('setPaths')
logs = dir([PATHS.FILES filesep '*.xlsx']);
logs = logs(not(contains({logs.name}, '~')));

for i = 1:length(logs)
    path2log = [logs(i).folder filesep (logs(i).name)];
    logcell{i} = bv_log2Table(path2log);
end

T1 = logcell{1};
for i = 2:size(logcell,2)
    T2 = logcell{i};
    T2Missing = setdiff(T1.Properties.VariableNames, T2.Properties.VariableNames);
    T1Missing = setdiff(T2.Properties.VariableNames, T1.Properties.VariableNames);
    T2 = [T2 array2table(nan(height(T2), numel(T2Missing)), 'VariableNames', T2Missing)];
    T1 = [T1 array2table(nan(height(T1), numel(T1Missing)), 'VariableNames', T1Missing)];
    
    for colname = T2Missing
        if iscell(T1.(colname{1}))
            T2.(colname{1}) = cell(height(T2), 1);
        end
    end
    for colname = T1Missing
        if iscell(T2.(colname{1}))
            T1.(colname{1}) = cell(height(T1), 1);
        end
    end
    
    
    T1 = [T1; T2];
end

T_all = T1;
T_all.wave(contains(T_all.wave, '3y')) = {'3y'};
T_all.wave(contains(T_all.wave, '5m')) = {'5m'};
T_all.wave(contains(T_all.wave, '10m')) = {'10m'};

switch class(subjectdatasummary)
    case 'table'
        subjectdatasummary = innerjoin(subjectdatasummary, T_all, 'Keys', {'pseudo', 'wave'});
    case 'struct'
        T_subjectdatasummary = struct2table(subjectdatasummary);
        T_subjectdatasummary = innerjoin(T_subjectdatasummary, T_all, 'Keys', {'pseudo', 'wave'});
        subjectdatasummary = table2struct(T_subjectdatasummary);
end



