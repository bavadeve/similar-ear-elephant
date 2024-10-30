function LF = bv_calculateLeafFraction(msts)

sz = size(msts);
N = sz(1);
ndims = length(sz);

if ndims > 3
    extraDims = sz(3:end);
    nwsz = [sz(1) sz(2) prod(sz(3:end))];
    msts = reshape(msts, nwsz);
end
    
LF = squeeze(sum(sum(msts)==1,2))./(N-1);

if ndims > 3
    LF = reshape(LF, extraDims);
end


