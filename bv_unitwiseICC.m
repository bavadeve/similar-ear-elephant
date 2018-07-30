function r_unit = bv_unitwiseICC(Ws, pc)

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

avg = squeeze(nanmean(nanmean(Ws, 3),4));

if nargin < 2
    pc = 0;
end

sqAvg = nansquareform(avg);
Y = prctile(sqAvg, pc);
thr = sqAvg>=Y;
    
n = size(Ws,3);
sqWs1 = zeros(n, sum(thr));
sqWs2 = zeros(n, sum(thr));
for i = 1:n
    currSq1 = nansquareform(Ws(:,:,i,1));
    currSq2 = nansquareform(Ws(:,:,i,2));
    
    sqWs1(i,:) = currSq1(thr);
    sqWs2(i,:) = currSq2(thr);
end
sqWs = cat(3,sqWs1,sqWs2);

m = size(sqWs,2);
r_unit = zeros(1,m);
corr_unit = zeros(1,m);
for i = 1:m
    curr = squeeze(sqWs(:,i,:));
    curr = curr(~any(isnan(curr),2),:);
    curr = curr(~any(isinf(curr),2),:);
    r_unit(i) = ICC(curr, '1-k');
    corr_unit(i) = corr(curr(:,1), curr(:,2));
end



