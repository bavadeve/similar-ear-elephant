cfg = [];
cfg.length = 5;
cfg.overlap = 0;
data = ft_redefinetrial(cfg, comp);

cfg = [];
cfg.channel = 1:20;
data = ft_selectdata(cfg, data);

cfg = [];
cfg.badPartsMatrix  = [(1:length(data.trial))', repmat(4,1,length(data.trial))'];
cfg.horzLim         = 10;
cfg.triallength     = 5;
cfg.scroll          = 1;
cfg.visible         = 'on';
scrollPlot          = scrollPlotData(cfg, data);