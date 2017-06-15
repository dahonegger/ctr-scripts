function Cube = phaseAvgdCube(Cube,nTides)
% 
% This script reads in a Cube, and pulls in previous Cubes at similar tidal
% phases, up until nTides before the current Cube.


% Use mean time of Cube
meanTime = epoch2Matlab(mean(Cube.timeInt(:)));

% Calculate tidal hour
[yTide,dnTide] = railroadBridgeCurrent;
tideHr = tideHour(meanTime,dnTide,yTide);

% Get datenums for this tidal hour 
allTides = tideHr2dn(tideHr,dnTide,yTide);

% Choose the previous [nTides] tides
idx = find(abs(allTides-meanTime)==min(abs(allTides-meanTime)));
relIdxVec = -2*(nTides-1):2:0;
dnVec = allTides(idx+relIdxVec);

% Load previous cubes
if isfield(Cube,'timex')
    Cube.timexStack = repmat(Cube.timex,1,1,nTides);
else
    Cube.timexStack = repmat(mean(Cube.data,3),1,1,nTides);
end
Cube.dnStack = meanTime*ones(1,nTides);
Cube.cubeNameStack = cell(nTides);
for i = 1:length(dnVec)
    Cube.cubeNameStack = cubeNameFromTime(dnVec(i));
    load(Cube.cubeNameStack,'timex')
    if ~exist('timex','var') || isempty(timex)
        load(Cube.cubeNameStack,'data')
        Cube.timexStack(:,:,i) = mean(data,3);
    else
        Cube.timexStack(:,:,i) = timex;
    end
    load(Cube.cubeNameStack,'timeInt')
    Cube.dnStack(i) = epoch2Matlab(mean(timeInt(:)));
end