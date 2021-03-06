function [trl, event] = trialfun_YOUth_resampled(cfg)
if ~isfield(cfg, 'trialdef')
    cfg.trialdef = [];
end

cfg.trialdef.attentiongrabber   = ft_getopt(cfg.trialdef, 'attentiongrabber');
cfg.trialdef.pretrig            = ft_getopt(cfg.trialdef, 'pretrig', 0);
cfg.trialdef.posttrig           = ft_getopt(cfg.trialdef, 'posttrig', 60);

% load event and hdr
event = ft_read_event(cfg.dataset);
hdr = ft_read_header(cfg.headerfile);

% remove all non-status triggers
EVtype = {event.type}';
statusIndx = strcmp(EVtype, 'STATUS');
event(~statusIndx) = [];

EVvalue = [event.value]';
EVsample = [event.sample]';
EVsample = ceil((cfg.Fs * EVsample) ./ hdr.Fs);
% EVvalue = EVvalue(end-3:end);
% EVsample = EVsample(end-3:end);

% only select correct triggers based on cfg.triger
triggerValues = [129 139];
[triggerIndx, i] = find(EVvalue == triggerValues);
condition = triggerValues(i);

% create trl
preTrig = cfg.trialdef.pretrig * cfg.Fs;
postTrig = cfg.trialdef.posttrig * cfg.Fs;
begsample = EVsample(triggerIndx) - preTrig;
endsample = EVsample(triggerIndx) + postTrig;

if ~isempty(begsample) && ~isempty(endsample)
    maxSamples = ceil((cfg.Fs * hdr.nSamples) ./ hdr.Fs);
    if endsample(end) > maxSamples
        endsample(end) = maxSamples;
    end
else
    trl = [];
    return
end

offset = (ones(length(begsample), 1 )*preTrig) .* -1;

%% the last part is again common to all trial functions
% return the trl matrix (required) and the event structure (optional)
trl = [begsample endsample offset condition'];
[~, sortIndx] = sort(trl(:,1));
trl = trl(sortIndx,:);

for i = 1:size(trl,1)-1
    if trl(i,2) > trl(i+1,1)
        trl(i,2) = trl(i+1,1)-1;
    end
end
   

end % function
