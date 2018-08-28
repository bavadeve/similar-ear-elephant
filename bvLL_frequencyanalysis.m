function [freq, fd] = bvLL_frequencyanalysis(data, freqrange, output, redefinetrial)

if nargin < 4
    redefinetrial = 0;
end
if nargin < 3
    output = 'powandcsd';
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

% fprintf('\t frequency analysis ... ')
cfg = [];
cfg.method      = 'mtmfft';
cfg.taper       = 'dpss';
cfg.output      = output;
cfg.tapsmofrq   = 1;
cfg.foilim      = [freqrange(1) freqrange(2)];
cfg.keeptrials  = 'yes';
cfg.pad         ='nextpow2';
freq = ft_freqanalysis(cfg, data);
fd = ft_freqdescriptives(cfg, freq);

% fprintf('done! \n')



