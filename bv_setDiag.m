function out = bv_setDiag(M, value)

[m,n,p]=size(M);
idx=find(speye(m,n));
xx=reshape(M,m*n,p);
xx(idx,:) = value;

out = reshape(xx, m,n,p);