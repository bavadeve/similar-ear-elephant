function fig_handle = scrollPlotData(cfg, data)

badPartsMatrix  = ft_getopt(cfg, 'badPartsMatrix');
horzLim         = ft_getopt(cfg, 'horzLim', 'full');
scroll          = ft_getopt(cfg, 'scroll', 0);
visible         = ft_getopt(cfg, 'visible', 'off');
channel         = ft_getopt(cfg, 'channel', 'all');

if strcmp(horzLim, 'full')
    horzLim = length([data.time{:}])/data.fsample - (1/data.fsample);
end

cfg =[];
cfg.channel = channel;
evalc('data = ft_selectdata(cfg, data);');

openFigures     = findall(0,'type','figure');
nrOpenFigures   = length(openFigures);
fignum = nrOpenFigures + 1;

trialData = [data.trial{:}];
endTime = length(trialData)./data.fsample;
labels = data.label;

if isempty(badPartsMatrix)
    vTime = 0:1/data.fsample:length(trialData)/data.fsample - (1/data.fsample);
    
    startVal    = 0;
    endVal      = horzLim;
    
    startIndx = find(vTime==startVal);
    endIndx = find(vTime==endVal);
    
    vertLim = max(max(trialData))./5;
    
    limVector = vertLim:vertLim:vertLim*(size(trialData,1));
    limMatrix = repmat(limVector', 1, size(trialData,2));
    
    newGoodData = trialData + limMatrix;
    newBadData  = nan(size(newGoodData));
    
    fig_handle = figure(fignum);
    set(gca, 'FontSize', 20)
    plot(vTime(startIndx:endIndx) , newGoodData(:, startIndx:endIndx)', 'b')
    hold on
    plot(vTime(startIndx:endIndx) , newBadData(:, startIndx:endIndx)', 'b')
    hold off
    
    set(gca, 'YLim', [0 (max(limVector) + vertLim)], 'XLim', [startVal endVal])
    
    set(gca,'YTick',limVector)
    set(gca,'YTickLabel',labels)
    
    currPart = endVal / horzLim;
    nParts = endTime / horzLim;
    title(['part ' num2str(currPart) '/' num2str(nParts)])
    
    drawnow
    figure(fignum);
    
    if scroll
        scrollView(trialData, trialData, newBadData, vTime, endVal, startVal, horzLim, vertLim, fignum, endTime, labels)
    end
else
    badTrials               = unique(badPartsMatrix(:,1));
    
    goodTrials              = 1:1:length(data.trial);
    goodTrials(badTrials)   = [];
    
    tmpGoodData = data.trial;
    tmpGoodTime = data.time;
    
    for i = 1:size(badPartsMatrix,1)
        tmpGoodData{badPartsMatrix(i,1)}(badPartsMatrix(i,2),:) = nan(1, size(data.trial{1},2));
    end
    
    tmp = zeros(size(data.trial{1},1), length(data.trial));
    tmp(sub2ind(size(tmp), badPartsMatrix(:,2), badPartsMatrix(:,1))) = 1;
    
    [goodChannelsPerTrial, goodTrialsPerChannel] = find(tmp == 0);
    goodPartsMatrix = cat(2, goodTrialsPerChannel, goodChannelsPerTrial);
    
    tmpBadData = data.trial;
    tmpBadTime = data.time;
    
    for i = 1:length(goodPartsMatrix)
        tmpBadData{goodPartsMatrix(i,1)}(goodPartsMatrix(i,2),:) = nan(1, size(tmpBadData{goodPartsMatrix(i,1)},2));
    end
    
    for i = 1:length(goodTrials)
        tmpBadTime{goodTrials(i)} = nan(1, length(data.time{1}));
    end
    
    goodTrialData = [tmpGoodData{:}];
    goodTimeData = [tmpGoodTime{:}];
    
    vTime = 0:1/data.fsample:length(trialData)/data.fsample - (1/data.fsample);
    
    badTrialData = [tmpBadData{:}];
    badTimeData = [tmpBadTime{:}];
    
    if isempty(goodTrials)
        tmp = max([data.trial{:}],[],2);
        vertLim = mean(tmp);
    else
        tmp = max(goodTrialData, [], 2);
        vertLim = nanmean(tmp);
    end
    
    limVector = vertLim:vertLim:vertLim*(size(trialData,1));
    limMatrix = repmat(limVector', 1, size(trialData,2));
    
    newGoodData = goodTrialData + limMatrix;
    newBadData = badTrialData + limMatrix;
    
%     newGoodData = flipud(newGoodData);
%     newBadData = flipud(newBadData);
    
    startVal    = 0;
    endVal      = horzLim;
    
    startIndx = find(vTime==startVal);
    endIndx = find(vTime==endVal);
    
    if strcmp(visible, 'off')
        fig_handle = figure('Visible','off');
    else
        fig_handle = figure(fignum);
    end
    set(gca, 'FontSize', 20)
    plot(vTime(startIndx:endIndx), newGoodData(:,(startIndx:endIndx)), 'b')
    hold on
    plot(vTime(startIndx:endIndx), newBadData(:,(startIndx:endIndx)), 'r')
    hold off
    
    set(gca,'YTick',limVector)
    set(gca,'YTickLabel',labels)
    
    currPart = endVal / horzLim;
    nParts = endTime / horzLim;
    title(['part ' num2str(currPart) '/' num2str(nParts)])
    
    set(gca, 'YLim', [0 (max(limVector) + vertLim)], 'XLim', [0 horzLim])
    % axis([startVal endVal 0 (max(limVector) + vertLim) ])
    drawnow
    if scroll
        scrollView(trialData, goodTrialData, badTrialData,  vTime, endVal, startVal, horzLim, vertLim, fignum, endTime, labels)
    end
end

function scrollView(trialData, goodTrialData, badTrialData,  vTime, endVal, startVal, horzLim, vertLim, fignum, endTime, labels)
while 1
    while 1
        [keyIsDown,~,keyCode] = KbCheck;
        if keyIsDown
            
            if strcmp('RightArrow', KbName(keyCode)),
                if endVal + horzLim >= endTime
                    endVal = endTime;
                    startVal = endVal - horzLim;
                else
                    endVal = endVal + horzLim;
                    startVal = endVal - horzLim;
                end
                break
            end
            
            if strcmp('LeftArrow', KbName(keyCode)),
                if startVal - horzLim <= 0
                    startVal = 0;
                    endVal = startVal + horzLim;
                else
                    endVal = endVal - horzLim;
                    startVal = endVal - horzLim;
                    
                end
                break
            end
            
            if strcmp('w', KbName(keyCode))
                vertLim = vertLim / 1.5;
                limVector = vertLim:vertLim:vertLim*(size(trialData,1));
                limMatrix = repmat(limVector', 1, size(trialData,2));
                break
                
            end
            
            if strcmp('s', KbName(keyCode))
                vertLim = vertLim * 1.5;
                limVector = vertLim:vertLim:vertLim*(size(trialData,1));
                limMatrix = repmat(limVector', 1, size(trialData,2));
                break
            end
            
            if strcmp('-_', KbName(keyCode))
                horzLim = horzLim * 1.5;
                endVal = startVal + horzLim;
                break
            end
            
            if strcmp('=+', KbName(keyCode))
                horzLim = horzLim / 1.5;
                endVal = startVal + horzLim;
                break
            end
            
            
            if strcmp('q', KbName(keyCode))
%                 close all
                return
            end
            
        end
    end
    
    
    limVector = vertLim:vertLim:vertLim*(size(trialData,1));
    limMatrix = repmat(limVector', 1, size(trialData,2));
    
    newGoodData = goodTrialData + limMatrix;
    newBadData = badTrialData + limMatrix;
    
    startIndx = find(vTime==startVal);
    endIndx = find(vTime==endVal);
    
    fig_handle = figure(fignum);
    set(gca, 'FontSize', 20)
    plot(vTime(startIndx:endIndx) , newGoodData(:, startIndx:endIndx)', 'b')
    hold on
    plot(vTime(startIndx:endIndx), newBadData(:, startIndx:endIndx)', 'r')
    hold off
    
    set(gca, 'YLim', [0 (max(limVector) + vertLim)], 'XLim', [startVal endVal])
    
    set(gca,'YTick',limVector)
    set(gca,'YTickLabel',labels)
    
    currPart = endVal / horzLim;
    nParts = endTime / horzLim;
    title(['part ' num2str(currPart) '/' num2str(nParts)])
    
    drawnow
    figure(fignum);
    
end



