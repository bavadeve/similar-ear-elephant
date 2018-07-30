load Subject.mat

dataFiles = dir([subjectdata.subjectdir '*.mat']);
dataFileNames = {dataFiles.name};

% remove ICA files
boolICAFiles = strfind(dataFileNames, 'ICA');
IndexICAFiles = find(not(cellfun('isempty', boolICAFiles)));
dataFileNames(IndexICAFiles) = [];

figure;
for iData = 1:length(dataFileNames)
    clear data
    load(dataFileNames{iData})
    
    cfg = [];
    cfg.windowLength = 1000;
    cfg.noverlap = 50;
    cfg.freqrange = [1 250];
    
    subplot(ceil(length(dataFileNames)/2), 2, iData)
    magnitudeResponse(cfg, data)
    set(gca, 'YLim', [0 1000])
    
    graphTitle = strrep(data.preprocessOrder,'_',' ');
    title(graphTitle)
end

