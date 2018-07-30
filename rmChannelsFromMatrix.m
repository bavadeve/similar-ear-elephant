function WchanRemoved = rmNodesFromMatrix(W)

rmChannels = sum(isnan(W)) == size(W,2);

W(rmChannels, :) = [];
W(:, rmChannels) = [];

WchanRemoved = W;