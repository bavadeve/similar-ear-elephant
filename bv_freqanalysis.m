function [fd] = bv_freqanalysis(cfg, data)

currSubject = ft_getopt(cfg, 'currSubject');
saveData    = ft_getopt(cfg, 'saveData');
inputStr    = ft_getopt(cfg, 'inputStr');
outputStr   = ft_getopt(cfg, 'outputStr', 'freq');
freqrange   = ft_getopt(cfg, 'freqrange', [0 100]);

eval('setPaths')
eval('setOptions')

if nargin < 2
        
    try
        load([PATHS.SUBJECTS filesep currSubject filesep 'Subject.mat'], 'subjectdata')
    catch
        error('Subject.mat file not found')
    end
    
    disp(subjectdata.subjectName)
    try
        load([subjectdata.PATHS.(inputStr)])
        [~, preprocFilename, ~] = fileparts(subjectdata.PATHS.(inputStr));
        fprintf('\t %s found and loaded \n', preprocFilename)
    catch
        errorStr = sprintf('No data input variable given and no data found at subjectdata.PATHS.%s',...
            inputStr);
        error(errorStr)
    end
end


fprintf('\t starting frequency analysis ... ')
cfg = [];
cfg.method      = 'mtmfft';
cfg.taper       = 'dpss';
cfg.tapsmofrq   = 2;
cfg.output      = 'fourier';
cfg.foilim      = [freqrange(1) freqrange(2)];
cfg.pad         ='nextpow2';
cfg.keeptrials  = 'yes';
cfg.keeptapers  = 'yes';
evalc('freq = ft_freqanalysis(cfg, data);');
evalc('fd = ft_freqdescriptives(cfg, freq);');

fprintf('done! \n')

if strcmpi(saveData, 'yes')
    
    bv_saveData(subjectdata, fd, outputStr)
    
end


