function [subjectdata, varargout] = bv_check4data(subjectFolderPath, varargin)

nArgs = length(varargin);
try
    fprintf('\t loading Subject.mat ... ')
    load([subjectFolderPath filesep 'Subject.mat'])
    fprintf('done! \n')
catch
    error('No Subject.mat file found')
end

for i = 1:nArgs
    try
        [~, filename, ext] = fileparts(subjectdata.PATHS.(upper(varargin{i})));
        fprintf('\t loading %s%s ... ', filename, ext) 
        output = load(subjectdata.PATHS.(upper(varargin{i})));
        fprintf('done! \n')
        fields = fieldnames(output);
        eval('varargout{i} = output.(fields{1});');
    catch
        error('No data found for inputStr %s', varargin{i})
    end
end

