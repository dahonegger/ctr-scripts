function dnOut = tideHr2dn(tideHr,dnTide,yTide)
%
% This function calculates the real world times associated with a tidal
% hour, given a tidal time series.
%


% Compute zero-upcrossing times of tidal time series
tUp = zeroUpCrossing(dnTide,yTide);


dnOut = tUp + tideHr/24;





% Zero upcrossing subfunction
function tUp = zeroUpCrossing(t,y)

isCrossing = y(1:end-1).*y(2:end) < 0;
isUp = diff(y) > 0;

idx = find(isCrossing & isUp);

for i = 1:length(idx)
    tUp(i) = interp1(y(idx(i)-1:idx(i)+1),t(idx(i)-1:idx(i)+1),0,'linear');
end