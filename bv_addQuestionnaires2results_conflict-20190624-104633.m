function subjectresults = bv_addQuestionnaires2results(subjectresults, questionnaireString)

eval('setPaths')
eval('setOptions')

if not(iscell(questionnaireString))
    questionnaireStringTmp{1} = questionnaireString;
    questionnaireString = questionnaireStringTmp;
    clear questionnaireStringTmp
end

csvflags = dir([PATHS.FILES filesep '*.csv']);
csvnames = {csvflags.name};
questionnaireNames = csvnames(not(contains(csvnames, 'metadata')));
questionnaireNames = questionnaireNames(contains(questionnaireNames, questionnaireString));
questionnaireMetas = csvnames(contains(csvnames, 'metadata'));
questionnaireMetas = questionnaireMetas(contains(questionnaireMetas, questionnaireString));

fieldnames = cell(1,length(questionnaireNames));
for i = 1:length(questionnaireNames)
    currQuestionnaire = questionnaireNames{i};
    currQuestionnaire = strrep(currQuestionnaire, '-', '_');
    fieldnames{i} = currQuestionnaire(1:end-4);
    
    opts = detectImportOptions(questionnaireNames{i});
    opts = setvartype(opts, 'char');
    allQuestionnaires.(fieldnames{i}) = readtable(questionnaireNames{i},opts);
    allMetas.(fieldnames{i}) = readtable(questionnaireMetas{i}, opts);
end

if isfield(allQuestionnaires, 'IBQ_2')
    allQuestionnaires.IBQ_2.IBQ4_1_SC = repmat({'X'},height(allQuestionnaires.IBQ_2),1);
end

if contains('IBQ', questionnaireString)
    ibqFields = fieldnames(find(contains(fieldnames, 'IBQ')));
    allQuestionnaires.IBQ = [];
    for i = 1:length(ibqFields)
        allQuestionnaires.IBQ = [allQuestionnaires.IBQ; allQuestionnaires.(ibqFields{i})];
    end
    allQuestionnaires = rmfield(allQuestionnaires, ibqFields);
    allQuestionnaires.IBQ = removevars(allQuestionnaires.IBQ , 'IBQ2_1_SC'); % remove double question
end

for i = 1:length(subjectresults)
    currSubject = subjectresults(i).pseudocode;
    currSession = subjectresults(i).agegroup;
    if strcmpi(currSession(1),'0')
        currSession(1) = [];
    end
    
    for j = 1:length(questionnaireString)
        
        switch questionnaireString{j}
            case 'ASQ'
                fieldname2use = fieldnames{find(contains(fieldnames, questionnaireString) .* ...
                    contains(fieldnames, currSession))};
                currQuestionnaire = allQuestionnaires.(fieldname2use);
                subjIndx = find(contains(currQuestionnaire.subject, ...
                    currSubject));
                
                if isempty(subjIndx)
                    subjectresults(i).ASQ_score = NaN;
                    continue
                end
                
                subjectresults(i).ASQ_score = bv_calculateASQscore(currQuestionnaire(subjIndx,:));
                subjectresults(i).ASQ_version = currQuestionnaire.formversion(subjIndx);
                
            case 'IBQ'
                currQuestionnaire = allQuestionnaires.IBQ;
%                 currMeta = allMetas.IBQ
                
                switch currSession
                    case '5m'
                        subjIndx = find(contains(currQuestionnaire.subject, ...
                            currSubject) .* contains(currQuestionnaire.visit, ...
                            '4-7 maanden'));
                    case '10m'
                        subjIndx = find(contains(currQuestionnaire.subject, ...
                            currSubject) .* contains(currQuestionnaire.visit, ...
                            '9 - 12 maanden'));
                    otherwise 
                        error('Unknown subject session')
                end
                
                if isempty(subjIndx)
                    subjectresults(i).IBQ_score = NaN;
                    continue
                end
                
                subjectresults(i) = bv_calculateIBQscore(currQuestionnaire(subjIndx,:));
                subjectresults(i).IBQ_version = currQuestionnaire.formversion(subjIndx);

                
            otherwise
        end
    end
end
