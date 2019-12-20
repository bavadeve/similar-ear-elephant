function [date, time] = bv_readOutDateAndTimeBdf(bdffile)


fid = fopen(bdffile, 'r');

while 1
    currWord = textscan(fid, '%s, %s');
    currWordIsDatetime = length(regexp(currWord{1}{1}, '[0-9]')) == 17 && ...
        length(strfind(currWord{1}{1}, '.')) == 4;
    
    if currWordIsDatetime
        splitdateandtime = strsplit(currWord{1}{1}, '.');
        date = [splitdateandtime{1} '-' splitdateandtime{2} '-' splitdateandtime{3}(1:2)];
        time = [splitdateandtime{3}(3:4) ':' splitdateandtime{4} ':' splitdateandtime{5}(1:2)];
        break
    end
end

fclose all;


