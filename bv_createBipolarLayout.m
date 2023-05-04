function layout = bv_createBipolarLayout(labels, layout)

if any(contains(labels, 'EEG'))
    labels = cellfun(@(x) x(5:end), labels, 'un',0);
end

cfg = [];
cfg.layout = layout;
cfg.skipcomnt = 'yes';
cfg.skipscale = 'yes';
cfg.feedback = 'no';
standard_lay = ft_prepare_layout(cfg);

for i = 1:length(labels)
    clabels = strsplit(labels{i}, '-');
    idx = find(ismember(standard_lay.label, clabels));
    if length(idx) == 2
        lay.pos(i,:) = sum(standard_lay.pos(idx,:),1)/2;
    else
        lay.pos(i,:) = NaN;
    end
end
        
layout = [];
layout.label = labels;
layout.pos = lay.pos;
layout.width = repmat(0.1390, 1, length(lay.pos))';
layout.height = repmat(0.1043, 1, length(lay.pos))';
layout.outline = standard_lay.outline;
layout.mask = standard_lay.mask;

