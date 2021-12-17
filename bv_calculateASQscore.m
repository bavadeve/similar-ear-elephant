function scores = bv_calculateASQscore(asqTable)
% usage: scores = bv_calculateASQscore(asqTable)

switch asqTable.form{1}
    case 'ASQ5mnd'
        negatives = logical([0 0 0 1 0 0 0 0 1 0 1 1 0 1 0 1 0 1 0 0 0 0 1]);
        answers = asqTable{:,contains(asqTable.Properties.VariableNames, '_SC')};
        worries = asqTable{:,contains(asqTable.Properties.VariableNames, '_W_Y')};
        if length(negatives) ~= size(answers,2)
            error('Hardcoding does not match given asqTable')
        end
        for i = 1:size(answers,2)
            if negatives(i)
                answerScores(:, i) = strcmpi(answers(:,i), 'A') * 10 + strcmpi(answers(:,i), 'B') * 5;
            else
                answerScores(:, i) = strcmpi(answers(:,i), 'C') * 10 + strcmpi(answers(:,i), 'B') * 5;
            end
        end
        worriesScores = strcmpi(worries, '1') * 5;
        scores = sum(answerScores + worriesScores,2);
        
    case 'ASQ10mnd'
        negatives = logical([0 0 0 0 0 1 0 0 1 0 0 1 0 1 1 0 0 1 0 0 1 0 0 0 0 0 1]);
        answers = asqTable{:,contains(asqTable.Properties.VariableNames, '_SC')};
        worries = asqTable{:,contains(asqTable.Properties.VariableNames, '_W_X')};
        if length(negatives) ~= size(answers,2)
            error('Hardcoding does not match given asqTable')
        end
        for i = 1:size(answers,2)
            if negatives(i)
                answerScores(:, i) = strcmpi(answers(:,i), 'A') * 10 + strcmpi(answers(:,i), 'B') * 5;
            else
                answerScores(:, i) = strcmpi(answers(:,i), 'C') * 10 + strcmpi(answers(:,i), 'B') * 5;
            end
        end
        worriesScores = strcmpi(worries, '1') * 5;
        scores = sum(answerScores + worriesScores,2);
end