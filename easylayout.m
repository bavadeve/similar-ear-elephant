cfg = [];
cfg.layout = 'EEG1010';
cfg.channel = labels;
cfg.feedback ='yes';
cfg.skipcomnt = 'yes';
cfg.skipscale = 'yes';
lay = ft_prepare_layout(cfg);