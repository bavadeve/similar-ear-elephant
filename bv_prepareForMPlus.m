function [var2mplusOut, uniqueSubjects] = bv_prepareForMPlus(inTable, groupingVarName, var2mplusIn)
%  usage:
%   [ outVar ] = bv_prepareForMPlus( inVar, groupingVar )

if iscell(inTable.(var2mplusIn))
    doCell = true;
else
    doCell = false;
end

[g_indx, g_name] = findgroups(inTable.(groupingVarName));
uniqueSubjects = unique(inTable.pseudo, 'stable');
if doCell
    var2mplusOut = cell(length(uniqueSubjects),length(g_name));
else
    var2mplusOut = nan(length(uniqueSubjects),length(g_name));
end

for i = 1:length(uniqueSubjects)
    currSubject = uniqueSubjects{i};
    subjectIndx = find(ismember(inTable.pseudo, currSubject));
    sessionIndxPerSubject = ismember(g_name, inTable.(groupingVarName)(subjectIndx));
    
    if doCell
        if length(subjectIndx) > length(g_name)
            [var2mplusOut{i,:}] = deal('');
        elseif length(subjectIndx) ~= sum(sessionIndxPerSubject)
            [var2mplusOut{i,:}] = deal('');
        else
            for j = 1:length(subjectIndx)
                var2mplusOut{i, ...
                    ismember(g_name,inTable.(groupingVarName)(subjectIndx(j)))} = ...
                    inTable.(var2mplusIn){subjectIndx(j)};
            end
        end
    else
        if length(subjectIndx) > length(g_name)
            var2mplusOut(i,:) = NaN;
        elseif length(subjectIndx) ~= sum(sessionIndxPerSubject)
            var2mplusOut(i,:) = NaN;
        else
            for j = 1:length(subjectIndx)
                var2mplusOut(i, ...
                    ismember(g_name,inTable.(groupingVarName)(subjectIndx(j)))) = ...
                    inTable.(var2mplusIn)(subjectIndx(j));
            end
        end
    end
end
% if ~doCell
%     var2mplusOut = bv_nanZScore(var2mplusOut);
%     var2mplusOut(isnan(var2mplusOut)) = -999;
% end