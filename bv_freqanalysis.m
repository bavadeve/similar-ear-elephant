function [freq] = bv_freqanalysis(cfg, data)

currSubject = ft_getopt(cfg, 'currSubject');
saveData    = ft_getopt(cfg, 'saveData');
inputStr    = ft_getopt(cfg, 'inputStr');
outputStr   = ft_getopt(cfg, 'outputStr', 'freq');
optionsFcn  = ft_getopt(cfg, 'optionsFcn');
freqrange   = ft_getopt(cfg, 'freqrange', [0 100]);

global PATHS

if nargin < 2
    
    eval(optionsFcn)
    
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
cfg.method      = 'mtmconvol';
cfg.taper       = 'hanning';
cfg.output      = 'fourier';
cfg.foi         = freqrange(1):0.1:freqrange(2);
cfg.keeptrials  = 'yes';
cfg.toi         = '50%';
cfg.t_ftimwin   = ones(1, length(cfg.foi));
cfg.pad         = 'nextpow2';
freq = ft_freqanalysis(cfg, data);

fprintf('done! \n')

if strcmpi(saveData, 'yes')
    outputFilename = [subjectdata.PATHS.SUBJECTDIR filesep currSubject '_' outputStr '.mat'];
    
    subjectdata.analysisOrder = cat(2, subjectdata.analysisOrder, '-freq');
    
    fprintf('\t saving freq data to %s ... ', outputFilename)
    save(outputFilename, '-v7.3', 'freq')
    fprintf('done! \n')
    
    fprintf('\t saving subjectdata to Subject.mat file')
    save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'], 'subjectdata')
    fprintf('done! \n')
end


