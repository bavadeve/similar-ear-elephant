function [ rmComp ] = automaticCompRemoval(cfg, data, comp, freq)

blinkremoval = ft_getopt(cfg, 'blinkremoval');
gammaremoval = ft_getopt(cfg, 'gammaremoval');

rmComp = [];

if strcmpi(blinkremoval, 'yes')
    
    fprintf('\t searching for blink component ... ')
    
    clear R
    ring1 = not(cellfun(@isempty, strfind(data.label, 'Fp')));
    ring2 = not(cellfun(@isempty, strfind(data.label, 'AF')));
    ring3 = not(cellfun(@isempty, regexp(data.label, '^F[1234567890z]')));
    ring4 = not(cellfun(@isempty, regexp(data.label, '^FC[1234567890z]')));
    ring5 = not(cellfun(@isempty, regexp(data.label, '^C[1234567890z]')));
    % ring6 = not(cellfun(@isempty, regexp(data.label, '^CP[1234567890z]'))) ...
    %     | not(cellfun(@isempty, regexp(data.label, '^TP[78910]')));
    prefrontalIndx = ring1 | ring2 ;
    frontalIndx = ring1 | ring2 | ring3 | ring4 | ring5;
    
    trialdata   = [data.trial{:}];
    frontaldata = trialdata(frontalIndx,:);
    compdata    = [comp.trial{:}];
    
    R = corr(trialdata', compdata');
    
    [~, sortIndx] = sort(mean(abs(R(prefrontalIndx,:))), 'descend');
    
    %     load('~/git/eeg-graphmetrics-processing/templates/blinkTopo.mat')
    
    i = 1;
    while 1
        
        if i > min([10 length(sortIndx)])
            fprintf('\t \t None found \n')
            rmComp = [];
            break
        end
        
        currComp = sortIndx(i);
        
        R1 = mean(abs(R(ring1,currComp)));
        R2 = mean(abs(R(ring2,currComp)));
        R3 = mean(abs(R(ring3,currComp)));
        R4 = mean(abs(R(ring4,currComp)));
        R5 = mean(abs(R(ring5,currComp)));
        
        if R1 > R2 && R2 > R3 && R3 > R4 && R2 > R5
            rmComp = currComp;
            fprintf('component found (%s)! \n', num2str(rmComp))
            break
        end
        
        i = i + 1;
    end
end

if strcmpi(gammaremoval, 'yes')
    
    fprintf('\t searching for components with too high gamma ... ')
    
    output = 'pow';
    freqrange = [0.2 100];
    evalc('freq = bvLL_frequencyanalysis(comp, freqrange, output, 0);');
    
    lowgammastart = find(freq.freq == 25);
    lowgammaend = find(freq.freq == 45);
    highgammastart = find(freq.freq == 55);
    highgammaend = find(freq.freq == 85);

    meangamma = squeeze(mean(mean(freq.powspctrm(:,:,[lowgammastart:lowgammaend, highgammastart:highgammaend])),3));
    gammacomps = find(isoutlier(meangamma));
    
    if isempty(gammacomps)
        fprintf('none found! \n')
    else
        fprintf('done! \n')
    end
    
    rmComp = [rmComp gammacomps];
    
end