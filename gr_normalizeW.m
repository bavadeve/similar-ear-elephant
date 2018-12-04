function Wnrm = gr_normalizeW(W)
% Function to normalize adjacency matrices
%
% See also SQUAREFORM

Wsq = squareform(W);
Wsqnrm =  (Wsq - min(Wsq(:))) / (max(Wsq(:)) - min(Wsq(:)));
Wnrm = squareform(Wsqnrm);

