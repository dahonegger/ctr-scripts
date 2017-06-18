function wind = loadFTTechLog(fname,allFlag)
% loadFTTechLog: reads the .csv log of FTTech wind data logged by the OSU
% DAQ-PC, and returns a structure containing mean time and statistics.
% 
% OPTIONAL: 
% loadFTTechLog(fname,'all') also loads the full wind time series
%
% 2017-June-17 David Honegger

fid = fopen(fname,'rt');
try
    C = textscan(fid,'%f%f%f%f%f%f%3c%s%f%s%f%s%s','delimiter',',');
catch
    fclose(fid);
end
fclose(fid);

dateNumAll = datenum(C{1:6});
wind.dateNum = mean(datenum(C{1:6}));
wind.dateStr = datestr(wind.dateNum);
wind.timeZone = char(C{7}(1,:));
wind.recordLength = 0.1*round(10*diff(dateNumAll([1 end]))*86400);
wind.recordLengthUnits = 'sec';
wind.speed = round(100*mean(C{11}))/100;
wind.maxSpeed = max(C{11});
wind.speedUnits = 'm/s';
wind.direction = round(mean(C{9}));
wind.directionUnits = 'deg';

if nargin>1
    if strcmpi(allFlag,'all')
        wind.dateNumAll = dateNumAll;
        wind.speedAll = C{11};
        wind.directionAll = C{9};
    else
        error('Not a valid flag:\n   loadFTTechLog(fname,''all'') loads all wind data from record.\n')
    end
end
        