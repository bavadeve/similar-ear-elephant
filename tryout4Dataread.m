clear all
fclose('all');
fid = fopen('Matrix_RS1_results.txt', 'r');

while 1
    hdr1 = fgetl(fid);
    if hdr1==-1
        break
    end
    hdr1 = strsplit(hdr1, ' ');
    hdr1 = hdr1(1:end-1);
    fileName = hdr1{2};
    
    hdr2 = fgetl(fid);
    hdr2 = strsplit(hdr2, ' ');
    hdr2 = hdr2(1:end-1);
    epochNumber = str2double(hdr2{2});
    
    fgetl(fid);
    
    while 1
        
        
        line = fgetl(fid);
        
        if isempty(line)
            Ws(:,:,epochNumber) = W;
            clear W
            break
        end
        
        line = strsplit(line, ' ');
        line = line(1:end-1);
        line = cellfun(@str2num, line);
        
        if ~exist('W', 'var')
            W = [];
        end
        
        W = [W; line];
        
    end
end
