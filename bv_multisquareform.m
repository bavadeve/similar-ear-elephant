function Wsq = bv_multisquareform(Ws)

sz = size(Ws);

if length(sz) > 3
    WsNew = reshape(Ws, [sz(1) sz(2) prod(sz(3:end))]);
else
    WsNew = Ws;
end

Wsq = zeros(size(WsNew,3), length(squareform(WsNew(:,:,1))));
for i = 1:size(WsNew,3)
    Wsq(i,:) = squareform(WsNew(:,:,i));
end

if length(sz) > 3
    Wsq = reshape(Wsq, [sz(3:end), size(Wsq,2)]);
end
    