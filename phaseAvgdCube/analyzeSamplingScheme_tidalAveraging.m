rotLength = 1.25;
runScheme1 = (0:64-1)*rotLength;
runScheme2 = (0:512-1)*rotLength;

obsStart = datenum([2017 06 06 0 0 0]);
obsEnd = obsStart + 3;
% obsEnd = datenum([2017 07 01 0 0 0]);

hourlyStartTimes = (0:2:58)/60;
hourlyEndTimes = hourlyStartTimes + runScheme1(end)/60/60;
hourlyMeanTimes = mean([hourlyStartTimes;hourlyEndTimes]);

dailyStartTimes = [];
dailyEndTimes = [];
for thisHour = 0:23
    dailyStartTimes = [dailyStartTimes, thisHour + hourlyStartTimes];
    dailyEndTimes = [dailyEndTimes, thisHour + hourlyEndTimes];
end
dailyStartTimes = dailyStartTimes/24;
dailyEndTimes = dailyEndTimes/24;
dailyMeanTimes = mean([dailyStartTimes;dailyEndTimes]);

recordStartTimes = [];
recordEndTimes = [];
thisDay = obsStart;
recordStartTimes = [recordStartTimes, thisDay + dailyStartTimes];
recordEndTimes = [recordEndTimes, thisDay + dailyEndTimes];
thisDay = thisDay + 1;
while recordEndTimes < obsEnd
    recordStartTimes = [recordStartTimes, thisDay + dailyStartTimes];
    recordEndTimes = [recordEndTimes, thisDay + dailyEndTimes];
    
    thisDay = thisDay + 1;
end
overIdx = find(recordEndTimes>obsEnd);
recordStartTimes(overIdx) = [];
recordEndTimes(overIdx) = [];

recordMeanTimes = mean([recordStartTimes;recordEndTimes]);

%%
% interp tide levels
recordStartTideLevels = interp1(dnTide,yTide,recordStartTimes);
recordEndTideLevels = interp1(dnTide,yTide,recordEndTimes);
recordMeanTideLevels = interp1(dnTide,yTide,recordMeanTimes);


%%

figure;
    plot(dnTide,yTide,'-b')
    hold on
    
plot([recordStartTimes;recordEndTimes],[recordStartTideLevels;recordEndTideLevels],'-r')
plot(recordMeanTimes,recordMeanTideLevels,'ob','markerfacecolor','r')

xlim([recordStartTimes(1) recordEndTimes(end)])
%%

[recordStartTideHrs] = tideHour(recordStartTimes,dnTide,yTide);
recordEndTideHrs = tideHour(recordEndTimes,dnTide,yTide);
[recordMeanTideHrs,tideNum] = tideHour(recordMeanTimes,dnTide,yTide);

%%

figure;hold on
% plot([recordStartTideHrs;recordEndTideHrs],[recordStartTideLevels;recordEndTideLevels],'-r')
plot(recordMeanTideHrs,recordMeanTideLevels,'o-r','markerfacecolor','r')

histogram(recordMeanTideHrs,'binwidth',2/60)
%%

% tideHrGrid = 0:1/3:max(recordMeanTideHrs);
% windowHalfWidth = 10/60; % A touch less than full
% 
% nRuns = nan*size(tideHrGrid);
% for i = 1:length(tideHrGrid)
%     idx = find(recordMeanTideHrs>=(tideHrGrid(i)-windowHalfWidth)...
%         & recordMeanTideHrs<=(tideHrGrid(i)+windowHalfWidth));
%     nRuns(i) = length(idx);
% end