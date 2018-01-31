function [tideHr,dnRef,tideNum] = tideHourGeneral(dnIn,dnTide,yTide,ref,allowNeg)
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
% ref           = [optional, default=up] Tidal reference: [up,down,high,low]
% allowNeg      = [optional, default=false] Force reference to nearest tide
%                  time-datum, permitting negative values
%
% OUTPUT:
% 
% tideHour      = Hours after tidal zero-upcrossing
% dnRef         = Time (datenum) of reference tidal phase
% tideNum       = Tide number since beginning of tide record
%
% 2017-Jun-10 David Honegger
%
if ~exist('ref','var') || isempty(ref)
    ref = 'up';
end

if ~exist('allowNeg','var') || isempty(allowNeg)
    allowNeg = false;
end

switch lower(ref)
    case 'up'
        refTime = zeroUpCrossing(dnTide,yTide);
    case 'down'
        refTime = zeroUpCrossing(dnTide,-yTide);
    case 'high'
        refTime = zeroUpCrossing(dnTide(1:end-1)+diff(dnTide)/2,diff(smooth(-yTide,15)));
    case 'low'
        refTime = zeroUpCrossing(dnTide(1:end-1)+diff(dnTide)/2,diff(smooth(yTide,15)));
end

% 
if any(min(dnIn(:)))<min(refTime) || any(max(dnIn(:)))>max(refTime)
    warning('tideHour.m: At least one input time is outside reference record.')
end

% Assign tide numbers to refTime

%%%%%% THIS IS TO GIVE TIDE NUMBER OF THE MONTH %%%%%%
% tDv = datevec(refTime);
% tDv(:,3:end) = 0;
% changeIdx = [find(diff(datenum(tDv)));length(refTime)];
% tNum = 1:changeIdx(1);
% for i = 2:length(changeIdx)
%     tNum = [tNum 1:diff(changeIdx(i-1:i))];
% end
%%%%%% /THIS IS TO GIVE TIDE NUMBER OF THE MONTH %%%%%%

%%%%%% THIS IS TO JUST GIVE TIDE NUMBER FROM START OF RECORD %%%%%%
tNum = 1:length(refTime);   
%%%%%% /THIS IS TO JUST GIVE TIDE NUMBER FROM START OF RECORD %%%%%%
    
% 
tideDay = nan(size(dnIn));
dnRef   = nan(size(dnIn));
tideNum = nan(size(dnIn));
for i = 1:length(dnIn)
    dist = dnIn(i) - refTime;
    if allowNeg
        [thisDist,idx] = min(abs(dist));
        thisDist = thisDist.*sign(dist(idx));
    else
        [thisDist,idx] = min(dist(dist>=0));
    end
    if ~isempty(thisDist)
        tideDay(i) = thisDist;
        dnRef(i)   = refTime(idx);
        tideNum(i) = tNum(idx);
    else
        tideDay(i) = nan;
        dnRef(i)   = nan;
        tideNum(i) = nan;
    end
end

tideHr = tideDay*24;


end
% Zero upcrossing subfunction
function [tUp,tRef] = zeroUpCrossing(t,y)

    isCrossing = y(1:end-1).*y(2:end) < 0;
    isUp = diff(y) > 0;

    idx = find(isCrossing & isUp);
    tRef = t(idx);

    tUp = nan(size(idx));
    for i = 1:length(idx)
        tUp(i) = interp1(y(idx(i)-1:idx(i)+1),t(idx(i)-1:idx(i)+1),0,'linear');
    end
    
end