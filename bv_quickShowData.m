function bv_quickShowData(data)

cfg = [];
cfg.viewmode = 'vertical';
cfg.ylim = [-100 100];
cfg.blocksize = 10;
cfg.continuous = 'yes';
ft_databrowser(cfg, data)