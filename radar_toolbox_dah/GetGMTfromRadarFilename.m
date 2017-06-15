%function to convert from a radar file name to year, month and day in GMT
%time. It returns a structure with the data

function [results]=GetGMTfromRadarFilename(fname,year,utcOffset,results)

% results.startTime.year=year;
% %the hour in the filename is EST, which is 5 hours off from GMT.we need to
% %correct the day accordingly
% results.startTime.minute=str2num(fname(7:8));
% results.startTime.seconds=0;
% dummyhour=str2num(fname(5:6))+utcOffset; %convert to GMT
% if dummyhour>=24
%     dummyday=str2num(fname(2:4))+1; %fix the day, rolling over the next day in GMT time
%     results.startTime.hour=dummyhour-24;
% else
%     dummyday=str2num(fname(2:4));
%     results.startTime.hour=dummyhour;    
% end
% [results.startTime.month,results.startTime.day]=yearday2MonthDay(dummyday,results.startTime.year); %

% Matlab is smart so we don't have to manually bookkeep days ... just do
% this!

ss = 0;
mn = str2num(fname(7:8));
hr = str2num(fname(5:6))+utcOffset; % convert to UTC
dy = str2num(fname(2:4)); % Julian Day
mo = 0; % Matlab automatically adds months
yr = year;

dateNum = datenum([yr mo dy hr mn ss]);
dateVec = datevec(dateNum);
results.startTime.year = dateVec(1);
results.startTime.month = dateVec(2);
results.startTime.day = dateVec(3);
results.startTime.hour = dateVec(4);
results.startTime.minute = dateVec(5);

disp('I Used the New GetGMTfromRadarFilename!')