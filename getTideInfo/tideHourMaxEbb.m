function [tideHr,tideNum] = tideHourMaxEbb(dnIn,dnTide,yTide)
%
% This script converts the current time to tide hour (hour after
% zero-upcrossing) using the tidal time series provided. It'd be smart to
% make sure the time zone is consistent between the two records!
% 
% INPUT:
% 
% dnIn          = Matlab datenum of time in question
% dnTide        = Matlab datenum vector of tidal time series
% yTide         = Vector of tidal values (e.g., elevation or current)
%
% OUTPUT:
% 
% tideHour      = Hours after tidal zero-upcrossing
% tideNum       = Tide number since beginning of month
%
% 2017-Jun-10 David Honegger
%


% Compute zero-upcrossing times of tidal time series
tUp = zeroUpCrossing(dnTide(1:end-1)+diff(dnTide)/2,diff(yTide));

% 
if min(dnIn)<min(tUp) || max(dnIn)>max(tUp)
    warning('tideHour.m: Input time is outside reference record.')
end

% Assign tide numbers to tUp
tDv = datevec(tUp);
tDv(:,3:end) = 0;
changeIdx = [find(diff(datenum(tDv)));length(tUp)];
tNum = 1:changeIdx(1);
for i = 2:length(changeIdx)
    tNum = [tNum 1:diff(changeIdx(i-1:i))];
end
    
% 
tideDay = nan(size(dnIn));
for i = 1:length(dnIn)
    dist = dnIn(i) - tUp;
    [previousDist,idx] = min(dist(dist>=0));
    if ~isempty(previousDist)
        tideDay(i) = previousDist;
        tideNum(i) = tNum(idx);
    else
        tideDay(i) = nan;
        tideNum(i) = nan;
    end
end

tideHr = tideDay*24;



% Zero upcrossing subfunction
function tUp = zeroUpCrossing(t,y)

isCrossing = y(1:end-1).*y(2:end) < 0;
isUp = diff(y) > 0;

idx = find(isCrossing & isUp);

for i = 1:length(idx)
    tUp(i) = interp1(y(idx(i)-1:idx(i)+1),t(idx(i)-1:idx(i)+1),0,'linear');
end