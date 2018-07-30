function bv_plotDataOnTopoplot(Ws, labels, propThr)

addpath('~/MatlabToolboxes/Colormaps/')

if nargin < 1
    error('Input variable W not given')
end
if nargin < 2
    error('Input variable labels not given')
end
if nargin < 3
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
        subplot(floor(sqrt(size(Ws,3))), ceil(sqrt(size(Ws,3))), currW)
    end
    
    fprintf('creating topoplot %s...', num2str(currW))
    hold on
    
    sqW = squareform(W);
    I = find(sqW);
    
    norm_data = (sqW(I) - min(sqW(I))) / ( max(sqW(I)) - min(sqW(I)) );
    
    sqW(I) = norm_data;
    weights = squareform(sqW);
    
    if nansum(squareform(W))~=0
        steps = sum(squareform(W)>0);
        c = colormap(spring(steps));
        
        wMin = 1;
        wMax = 5;
        wRange = wMax - wMin;
        w = wMin:wRange/steps:wMax - wRange/steps;
        
        
        counter = 0;
        for i = 1:size(W,1)
            for j = 1:size(W,2)
                counter = counter + 1;
                
                if W(i,j)==0
                    continue
                end
                
                
                cCurr = ceil(W(i,j) / (max(max(W))-min(min(W(W>0)))) * sum(squareform(W)>0));
                
                x = lay.pos([i j],1);
                y = lay.pos([i j],2);
                h(counter) = patch(x,y,weights(i,j)*[1 1],'edgecolor','flat','linewidth',(weights(i,j)+0.25)*5);
            end
        end
        
    end
    
    colormap plasma
    
    scatter(lay.pos(:,1), lay.pos(:,2), 10, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k')
%     labeloffset = 0.02;
%     text(double(lay.pos(:,1))+labeloffset, double(lay.pos(:,2)), lay.label , ...
%         'fontsize',10,'fontname','helvetica', ...
%         'interpreter','tex','horizontalalignment','left', ...
%         'verticalalignment','middle','color','k');
    line(lay.outline{1}(:,1), lay.outline{1}(:,2), 'LineWidth', 3, 'color', [0.5 0.5 0.5])
    
    axis equal
    axis off
    fprintf('done \n')
    colorbar
end
