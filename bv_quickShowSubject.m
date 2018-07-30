function bv_quickShowSubject(str, filestr, cfg)

if nargin < 3
    cfg = [];
end

if strcmpi(filestr,'RAW')
    israw = 1;
else
    israw = 0;
end

eval('setOptions')
eval('setPaths')

subject = dir([PATHS.SUBJECTS filesep str '*']);
nSubject = length(subject);

if nSubject ~= 1
    if nSubject == 0
        errorStr = sprintf('Subject with str-input: %s not found', str);
    elseif nSubject > 1
        errorStr = sprintf('Too many subjects found with str-input: %s', str);
    end
    error(errorStr)
end


disp(subject.name)
subjectFolderPath = [PATHS.SUBJECTS filesep subject.name];

if israw
    [subjectdata] = bv_check4data(subjectFolderPath);
    
    cfg.dataset = subjectdata.PATHS.DATAFILE;
    cfg.headerfile = subjectdata.PATHS.HDRFILE;
%     cfg.preproc.hpfilter = 'yes';
%     cfg.preproc.hpfreq = 1;
%     cfg.preproc.hpinstabilityfix = 'reduce';
    cfg.preproc.bsfilter = 'yes';
    cfg.preproc.bsfreq = [48 52];
    cfg.preproc.bsinstabilityfix = 'reduce';
    
    cfg.channel = 'EEG';
    cfg.viewmode = 'vertical';
%     cfg.blocksize = 60;
    cfg.ylim = [-150 150];
    fprintf('\t showing %s data \n', upper(filestr))
    evalc('ft_databrowser(cfg)');
    
else
    
    [~, data] = bv_check4data(subjectFolderPath, upper(filestr));
    cfg.viewmode = 'vertical';
    if length(data.trial) == 1
        cfg.blocksize = 60;
    end
    
    cfg.ylim = [-150 150];
    fprintf('\t showing %s data \n', upper(filestr))
    evalc('ft_databrowser(cfg, data)');
end

