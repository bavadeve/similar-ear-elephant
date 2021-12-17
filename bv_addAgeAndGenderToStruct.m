function dataOut = bv_addAgeAndGenderToStruct(dataIn)

if isstruct(dataIn)
    structbool = true;
    dataIn = struct2table(dataIn);
else
    structbool = false;
end
% 
% eval('setPaths')
% eval('setOptions')

ageGenderPath = ...
    '/Volumes/youth.data.uu.nl/research-grp-ydi-1911-01-velde/overig/Demo2.xlsx';
ageGenderPresent = ...
    exist(ageGenderPath, 'file');
if not(ageGenderPresent)
    error('Demo2.xlsx not found')
else
    ageGenderVar = readtable(ageGenderPath);
end

ageGenderVar(:,not(contains(ageGenderVar.Properties.VariableNames, ...
    {'pseudo', 'wave', 'geslacht', 'leeftijd'}))) = [];

ageGenderVar.Properties.VariableNames{...
    contains(ageGenderVar.Properties.VariableNames, 'leeftijd')} = ...
    'age';

ageGenderVar.Properties.VariableNames{...
    contains(ageGenderVar.Properties.VariableNames, 'geslacht')} = ...
    'gender';

for i = 1:height(dataIn)
    ag_indx = contains(ageGenderVar.pseudo, dataIn.pseudo{i}) & ...
        contains(ageGenderVar.wave, dataIn.wave{i});

    if ~isempty(find(ag_indx))
        dataIn.age(i) = ageGenderVar.age(ag_indx);
        dataIn.gender{i} = ageGenderVar.gender{ag_indx};
    else
        dataIn.age(i) = NaN;
        dataIn.gender{i} = '';
    end
end

if structbool
    dataOut = table2struct(dataIn);
else
    dataOut = dataIn;
end
