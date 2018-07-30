function bv_topoPlotValues(data)

freq = bvLL_frequencyanalysis(data, [1 100]);
% output = bv_getFrequencyInfo(data, 0);

cfg = [];
cfg.channel  = freq.label;
cfg.layout   = 'EEG1010';
cfg.feedback = 'no';
cfg.skipcomnt  = 'yes';
cfg.skipscale  = 'yes';
evalc('lay = ft_prepare_layout(cfg);');

[~, indxSort] = ismember(lay.label, freq.label);

% mDat = max(dat);
foi = [1:2:10];

nplots = length(foi);
nyplot = ceil(sqrt(length(foi)));
nxplot = ceil(nplots./nyplot);
figure; 

for i = 1:length(foi)
    [~,indx] = min(abs(freq.freq-foi(i)));
    dat = squeeze(mean(freq.powspctrm(:,:,indx)));
    dat = dat(indxSort);
    
    chanX = lay.pos(:,1);
    chanY = lay.pos(:,2);
    
    opt = {'interpmethod','v4','interplim','mask','gridscale',67,'outline',lay.outline, ...
        'shading','flat','isolines',6,'mask', lay.mask ,'style','surfiso', 'datmask', []};
    
    subplot(nyplot, nxplot, i)
    ft_plot_topo(chanX,chanY,dat,opt{:});
    colorbar
    axis equal
    axis off
    title(num2str(foi(i)));
end