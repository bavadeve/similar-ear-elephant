function bv_plotDataOnTopoplot(Ws, labels, propThr, subplotlabels, weighted, color)

if nargin < 4
    subplotlabels = strsplit(num2str(1:size(Ws,3)),' ');
end
if nargin < 5
    weighted = true;
end

addpath('~/MatlabToolboxes/Colormaps/')

if nargin < 1
    error('Input variable W not given')
end
if nargin < 2
    error('Input variable labels not given')
end
if nargin < 3 || isempty(propThr)
    doThresh = 0;
else
    doThresh = 1;
end
fprintf('preparing layout...')

cfg = [];
cfg.channel  = labels;
cfg.layout   = 'EEG1010';
cfg.feedback = 'no';
cfg.skipcomnt  = 'yes';
cfg.skipscale  = 'yes';
evalc('lay = ft_prepare_layout(cfg);');
fprintf('done \n')

[~, indxSort] = ismember(lay.label, labels);
indxSort = indxSort(indxSort>0);

% figure;
for currW = 1:size(Ws,3)
    
    W = squeeze(Ws(:,:,currW));
    W(isnan(W)) = 0;
    
    
    W = W(indxSort,:);
    W = W(:,indxSort);
    
    if doThresh
        W = threshold_proportional(W, propThr);
    end
    
    lay.pos = lay.pos(indxSort,:);
    lay.label = lay.label(indxSort);
    lay.width = lay.width(indxSort);
    lay.height = lay.height(indxSort);
    
    if size(Ws,3) > 1
        if size(Ws,3) == 2
            subplot(1,2,currW)
        else
            subplot(ceil(sqrt(size(Ws,3))), ceil(sqrt(size(Ws,3))), currW)
        end
    end
    
    fprintf('creating topoplot %s...', num2str(currW))
    hold on
    
    if weighted
        sqW = nansquareform(W);
        I = find(sqW);
        
        norm_data = (sqW(I) - min(sqW(I))) / ( max(sqW(I)) - min(sqW(I)) ) + 0.01;
        
        sqW(I) = norm_data;
        weights = squareform(sqW);
    end
    
    if nansum(squareform(W))~=0
       
        counter = 0;
        for i = 1:size(W,1)
            for j = 1:size(W,2)
                counter = counter + 1;
                
                if W(i,j)==0
                    continue
                end
                
                x = lay.pos([i j],1);
                y = lay.pos([i j],2);
                
                if ~weighted
                    h(counter) = patch(x,y, color, 'LineWidth',3 ); %,'edgecolor','flat','linewidth',(weights(i,j)+0.25)*5);
                else
                    h(counter) = patch(x,y, weights(i,j)*[1 1], 'edgecolor','flat','linewidth', (weights(i,j)+0.25)*5, 'edgealpha', (weights(i,j)-0.01)/2);
                end
            end
        end
        
    end
    
    if weighted
        colormap(viridis)
    end
    
    scatter(lay.pos(:,1), lay.pos(:,2), 10, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k')
    line(lay.outline{1}(:,1), lay.outline{1}(:,2), 'LineWidth', 3, 'color', [0.5 0.5 0.5])
    
    if not(isempty(subplotlabels))
        title(subplotlabels{currW})
    end
    axis equal
    axis off
    fprintf('done \n')
    
end
