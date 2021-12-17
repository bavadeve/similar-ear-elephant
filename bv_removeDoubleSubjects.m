function out = bv_removeDoubleSubjects(in)

for i = 1:height(in)
    subjNames{i} = [in.pseudo{i}, '_', in.wave{i}];
end

[d, id] = findgroups(subjNames);
counts = histc(d, 1:length(id));

doubleSubjects = id(counts>1);
for i = 1:length(doubleSubjects)
    indx = find(contains(in.subjectName, doubleSubjects{i}));
    [~,lateIndx] = max(datetime(in.testtime(indx)));
    incorrIndx = indx(lateIndx);
    in(incorrIndx,:) = [];
end
   
out = in;
