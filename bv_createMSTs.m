function msts = bv_createMSTs(As)

sz = size(As);
ndims = length(sz);

if ndims > 3
    extraDims = sz(3:end);
    nwsz = [sz(1) sz(2) prod(sz(3:end))];
    As = reshape(As, nwsz);
end
    
m = size(As, 3);

for i = 1:m
    A = As(:,:,i);
    D = weight_conversion(A, 'lengths');
    mst = graphminspantree(sparse(D), 'method', 'Kruskal');
    mst = mst + rot90(flipud(mst), -1);
    mst(mst>0) = 1./(mst(mst>0));
    msts(:,:,i) = full(mst);
end

if ndims > 3
    msts = reshape(msts, sz);
end


