function Cube = coGeoRectify(Cube,controlCube,doOverwrite)
%
% This function reads in a coRectified Cube
% e.g. ......
%   Cube = load('*_pol.mat');
%   Cube = coRectify(Cube);
%   Cube = coGeoRectify(Cube);
% ...... and then computes azimuthal cross-correlations at specified ranges 
% to co-rectify the azimuthal grid to a control grid that is (hopefully)
% properly rectified already.
% 
% Output is the same input Cube, but with the Cube.data field overwritten.
% The Cube.results.heading value is updated to match the control Cube
% heading, and the old heading value is renamed to:
% Cube.results.headingOld
%
% 2017-05-31 David Honegger
%


if nargin<2
    controlCube = 'geoRefTimex.mat';
    doOverwrite = true;
elseif nargin<3
    doOverwrite = true;
end

% xcorrelation parameters   
azimuthResolutionFactor = 1/20;    % Resolution factor of search grid (1 if same as input resolution, 1/2 if two gridpoints per input resolution cell, etc.)
minRangeToAnalyze = 400;           % Min range to consider (in pixels)
maxAziToAnalyze = 330/2;           % Max azimuth to consider (in degrees)
dRange = 50;                       % Range decimation of analysis (in pixels)
maxLag = 5;                        % Maximum lag to consider (in degrees)
threshLag = 5;                     % Frames with lags beyond this value don't get adjusted
interpMethod = 'spline';           % For griddedInterpolant.m ... 'linear','spline','nearest', etc.


% Input grid(s)
aziResolution = median(diff(Cube.Azi));
[RG,AZI] = ndgrid(Cube.Rg,Cube.Azi);

% HiRes grid
dAzi = aziResolution*azimuthResolutionFactor;
aziVec = 0:dAzi:360-dAzi;
[hires.RG,hires.AZI] = ndgrid(Cube.Rg,aziVec);

% Output grid: same as input grid:
if isfield(Cube,'dataCoRec')
    dataOut = Cube.dataCoRec;
else
    dataOut = Cube.data;
end

% Create looping vectors
minRange = find(diff(Cube.Rg),1,'first');
rangeIdxToAnalyze = minRangeToAnalyze:dRange:length(Cube.Rg);

% Create control frame
refCube = load(controlCube);
if isfield(refCube,'timex')
    refFrame = refCube.timex;
else
    refFrame = mean(refCube.data,3);
end
interpFuncXcorr = griddedInterpolant(...
    RG(rangeIdxToAnalyze,:),...
    AZI(rangeIdxToAnalyze,:,:),...
    single(refFrame(rangeIdxToAnalyze,:)),...
    interpMethod);
controlFrame = interpFuncXcorr(hires.RG(rangeIdxToAnalyze,:),hires.AZI(rangeIdxToAnalyze,:));

% Create offset interpolant
interpFuncOffset = griddedInterpolant(...
    RG(minRange:end,:),...
    AZI(minRange:end,:),...
    single(mean(Cube.data(minRange:end,:,:),3)),...
    interpMethod);

% Create test frame
% Interp test timex to hires azi grid
interpFuncXcorr.Values = single(mean(Cube.data(rangeIdxToAnalyze,:,:),3));
testFrame = interpFuncXcorr(hires.RG(rangeIdxToAnalyze,:),hires.AZI(rangeIdxToAnalyze,:));
        
% Loop thru ranges to analyze
for iRg = 1:length(rangeIdxToAnalyze)

    [r,lags] = xcorr(...
        controlFrame(iRg,1:maxAziToAnalyze/dAzi),...
        testFrame(iRg,1:maxAziToAnalyze/dAzi),...
        maxLag/dAzi,...
        'coeff');

    % Initialize or update mean xcorr ouput
    if iRg == 1
        rMean = r(:);
    else
        rMean = mean([r(:) rMean(:)],2);
    end

end
    
% Find lag associated with maximum mean xcorr
headingOffset = lags(find(rMean==max(rMean),1,'first'))*dAzi;
    
    
% If lag~=0, interpolate test frame to control grid
if headingOffset
    if abs(headingOffset) < threshLag
        fprintf('Shifting Cube data by %.2f degrees:\n',headingOffset)
        for iRot = 1:size(Cube.data,3)
            fprintf('.');if mod(iRot,64)==0;fprintf('\n');end
            interpFuncOffset.GridVectors = {Cube.Rg(minRange:end),Cube.Azi + headingOffset};
            interpFuncOffset.Values = single(Cube.data(minRange:end,:,iRot));
            dataOut(minRange:end,:,iRot) = uint8(interpFuncOffset(RG(minRange:end,:),AZI(minRange:end,:)));
        end
            fprintf('Done.\n')
    else
        fprintf('Max lag threshold exceeded.\n')
    end
else
    fprintf('No shift.\n')
end
      
    
Cube.results.headingOld = Cube.results.heading;
Cube.results.heading = refCube.results.heading;
Cube.headingOffset = headingOffset;
if doOverwrite
    Cube.data = dataOut;
else
    Cube.dataCoGeoRect = dataOut;
end