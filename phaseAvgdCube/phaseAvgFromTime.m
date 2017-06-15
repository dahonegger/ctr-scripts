function Cube = phaseAvgFromTime(dnIn,nTides)
% 
% This script reads in a Cube, and pulls in previous Cubes at similar tidal
% phases, up until nTides before the current Cube.

meanTime = dnIn;

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
for i = 1:length(dnVec)
    cubeName = cubeNameFromTime(dnVec(i));
    [frame,dnOut] = getWavg(cubeName,dnVec(i),64);
    if i==1
        % Initialize cube
        Cube = load(cubeName,'Azi','Rg','results','timeInt');
        Cube.dnStack(i) = dnOut;
        Cube.timexStack = repmat(frame,1,1,nTides);
        Cube.cubeNameStack = cell(nTides);
    else
        Cube.timexStack(:,:,i) = frame;
        Cube.dnStack(i) = dnOut;
    end
    Cube.cubeNameStack{i} = cubeName;
end