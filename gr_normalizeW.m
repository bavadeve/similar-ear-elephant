function Wnrm = gr_normalizeW(W)
% Function to normalize adjacency matrices
%
% See also SQUAREFORM

Wsq = nansquareform(W);

if ~all(ismember(unique(Wsq, 'sorted'), [0 1]))
    Wsqnrm = Wsq;
    Wsqnrm(Wsqnrm > 0) = (Wsqnrm(Wsqnrm > 0) - min(Wsqnrm(Wsqnrm > 0))) / ...
        (max(Wsqnrm(Wsqnrm > 0)) - min(Wsqnrm(Wsqnrm > 0)));
    Wnrm = squareform(Wsqnrm);
else
    Wnrm = W;
end



