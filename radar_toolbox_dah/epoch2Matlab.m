function [datenumTime] = epoch2Matlab(unixTime)

datenumTime = NaN*zeros(size(unixTime));
for i = 1:size(unixTime,1)
    for j = 1:size(unixTime,2)
        datenumTime(i,j) = datenum([1970,1,1,0,0,unixTime(i,j)]);
    end
end