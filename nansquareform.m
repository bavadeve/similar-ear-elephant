function Z = nansquareform(Y)

if isvector(Y)
    dir = 'tomatrix';
else
    dir = 'tovector';
end

switch(dir)
    case 'tomatrix'
        Z = squareform(Y);
        ncols = size(Z,1);
        Z(1:ncols+1:end) = NaN;
    case 'tovector'
        ncols = size(Y,1);
        Y(1:ncols+1:end) = 0;
        Z = squareform(Y);
end

