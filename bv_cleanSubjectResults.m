function [subjectoutput, subjectsummary] = bv_cleanSubjectResults(subjectoutput, subjectsummary);

if nargin < 2 
    error('Please input both subjectoutput and subjectsummary')
end

subjectnames = {subjectsummary.subjectName};
subjectwithoutsession = cellfun(@(v) v(1:5), subjectnames, 'Un', 0);
b = cellfun(@(x) sum(ismember(subjectwithoutsession,x)),subjectwithoutsession);

subj_sel = b==2;
subjectoutput = subjectoutput(subj_sel);
subjectsummary = subjectsummary(subj_sel);



