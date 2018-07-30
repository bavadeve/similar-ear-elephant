function [trl, event] = trialfun_selectall(cfg)
%% the first part is common to all trial functions
% read the header (needed for the samping rate) and the events

%% from here on it becomes specific to the experiment and the data format
% for the events of interest, find the sample numbers (these are integers)
% for the events of interest, find the trigger values (these are strings in the case of BrainVision)

% load event and hdr
hdr = ft_read_header(cfg.headerfile);
event = ft_read_event(cfg.dataset);

trl = [hdr.nSamplesPre hdr.nSamples 0];

end % function
