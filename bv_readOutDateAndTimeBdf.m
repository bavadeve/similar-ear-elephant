function [date, time] = bv_readOutDateAndTimeBdf(bdffile)

fid = fopen(bdffile, 'r');
b = textscan(fid, '%s, %s');
c = textscan(fid, '%s, %s');
dateandtime = c{1}{1};

splitdateandtime = strsplit(dateandtime, '.');
date = [splitdateandtime{1} '-' splitdateandtime{2} '-' splitdateandtime{3}(1:2)];
time = [splitdateandtime{3}(3:4) ':' splitdateandtime{4} ':' splitdateandtime{5}(1:2)];
fclose all
