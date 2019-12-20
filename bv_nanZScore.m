function [zs,xmu,xsigma] = bv_nanZScore(X)

if any(isnan(X(:)))
    xmu=nanmean(X);
    xsigma=nanstd(X);
    zs=(X-repmat(xmu,length(X),1))./repmat(xsigma,length(X),1);
else
    [zs,xmu,xsigma]=zscore(X);
end