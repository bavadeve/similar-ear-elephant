function r = bv_scanwiseICC(Ws)

sz = size(Ws);
if sz(end) ~= 2
    error('Scan session dimension not last in Ws. Please redo your Ws dimensions')
end

if sz(1) ~= sz(2)
    error('Your Ws do not consist of square connectivity matrices')
end

if length(sz) > 4
    error('More than 4 dimensions found. Unknown dimension ... ')
end

scAvg = zeros(size(Ws,3), size(Ws,4));
for iWs = 1:size(Ws,3)
    for jWs = 1:size(Ws,4)
        scAvg(iWs, jWs) = nanmean(nansquareform(Ws(:,:,iWs, jWs)));
    end
end

r = ICC(scAvg, '1-k');