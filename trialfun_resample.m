function [trl, event] = trialfun_resample(cfg)

%% load event and hdr
event = ft_read_event(cfg.headerfile);
hdr = ft_read_header(cfg.headerfile);

evType = {event.type};
statusIndx = contains(evType, 'STATUS');
event = event(statusIndx);

evSample = [event.sample];
evValue = [event.value];





