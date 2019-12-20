function msts = bv_createMSTs(As)

m = size(As, 3);

for i = 1:m
    A = As(:,:,i);
    D = weight_conversion(A, 'lengths');
    mst = graphminspantree(sparse(D), 'method', 'Kruskal');
    mst = mst + rot90(flipud(mst), -1);
    mst(mst>0) = 1./(mst(mst>0));
    msts(:,:,i) = full(mst);
end

