function [freq, fd] = bvLL_frequencyanalysis(data, freqrange, output, redefinetrial)

if nargin < 4
    redefinetrial = 0;
end
if nargin < 3
    output = 'fourier';
end
if nargin < 2
    error('Please input data')
end
if nargin < 1
    error('Please input config file')
end

if redefinetrial
    cfg =[];
    cfg.length = 5;
    cfg.overlap = 0;
    data = ft_redefinetrial(cfg, data);
end

cfg = [];
cfg.method      = 'mtmfft';
cfg.taper       = 'dpss';
cfg.tapsmofrq   = 1;
cfg.output      = output;
cfg.toi         = '50%';
cfg.foi         = freqrange(1):0.25:freqrange(2);
cfg.t_ftimwin   = ones(1, length(cfg.foi))*1;
cfg.pad         ='nextpow2';
cfg.keeptrials  = 'yes';
cfg.keeptapers  = 'yes';
evalc('freq = ft_freqanalysis(cfg, data);');
evalc('fd = ft_freqdescriptives(cfg, freq);');

