function [WchanRemoved, rmChanIndx] = rmNodesFromMatrix(W)

rmChannels = sum(isnan(W)) == size(W,2);
rmChanIndx = find(rmChannels);

W(rmChannels, :) = [];
W(:, rmChannels) = [];

WchanRemoved = W;