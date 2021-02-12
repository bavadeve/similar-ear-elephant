function [artefactdef] = bv_createArtefactStruct(cfg, data)

inputStr        = ft_getopt(cfg, 'inputStr');
outputStr       = ft_getopt(cfg, 'outputStr');
saveData        = ft_getopt(cfg, 'saveData');
currSubject     = ft_getopt(cfg, 'currSubject');
pathsFcn        = ft_getopt(cfg, 'pathsFcn');
cutintrials     = ft_getopt(cfg, 'cutintrials');
triallength     = ft_getopt(cfg, 'triallength');
overwrite       = ft_getopt(cfg, 'overwrite', 'no');

if nargin < 2
    if isempty(pathsFcn)
        error('please add options function cfg.pathsFcn')
    else
        eval(pathsFcn)
    end
    
    disp(currSubject)
    subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
    [subjectdata] = bv_check4data(subjectFolderPath);
    if strcmpi(overwrite, 'no')
        if isfield(subjectdata.PATHS, upper(outputStr))
            if exist(subjectdata.PATHS.(upper(outputStr)), 'file')
                fprintf('\t !!!%s already found, not overwriting ... \n', upper(outputStr))
                artefactdef = [];
                return
            end
        end
    end

    [~, data] = bv_check4data(subjectFolderPath, inputStr);
    
end

if strcmpi(cutintrials, 'yes')
    cfg = [];
    cfg.length = triallength;
    cfg.overlap = 0;
    evalc('data = ft_redefinetrial(cfg, data);');
end

fprintf('\t calculating artefact levels ... ')
for i = 1:length(data.trial)
        artefactdef.kurtosis.levels(:,i) = kurtosis(data.trial{i}, [], 2);
        artefactdef.variance.levels(:,i) = std(data.trial{i}, [], 2).^2;
        artefactdef.flatline.levels(:,i) = 1./(abs(max(data.trial{i},[],2) - min(data.trial{i},[],2)));
        artefactdef.range.levels(:,i) = max(data.trial{i}, [], 2) - min(data.trial{i}, [], 2);
        artefactdef.abs.levels(:,i) = max(abs(data.trial{i}), [],2);
end

% artefactdef.jump.levels = zeros(length(data.label), length(data.trial));
% counter = 0;
% for i = 1:length(data.label)
%     cfg = [];
%     cfg.artfctdef.jump.channel = data.label{i};
%     cfg.continuous = 'no';
%     evalc('[tmp,artifact] = ft_artifact_jump(cfg, data);');
%     for j = 1:size(artifact,1)
%         counter = counter + 1;
%         [~,sel] = min(abs(mean(data.sampleinfo(:,1:2),2) - mean(artifact(j,:))));
%         artefactdef.jump.levels(i,sel) = 1;
%     end
% end

fprintf('done! \n')

artefactdef.sampleinfo = data.sampleinfo;

if strcmpi(saveData, 'yes')
       
    bv_saveData(subjectdata, artefactdef, outputStr);
    
end