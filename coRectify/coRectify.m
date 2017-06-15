function Cube = coRectify(Cube,doOverwrite)
%
% This function reads in a Cube (e.g. Cube = load('*_pol.mat');) and
% computes azimuthal cross-correlations at specified ranges to co-register
% all frames. The frame with least likelihood of having a trigger-skip is
% used as the control.
% 
% Output is the same input Cube, but with the Cube.data field overwritten.
% If selected (doOverwrite = false), a new field will be added instead:
% Cube.dataCoRect
%
% A new field with heading offset values is added:
% Cube.headingOffset        = Offset vector utilized in azimuthal shifts
%                             (newHeading = Cube.results.heading + Cube.headingOffset)
%
% 2017-05-31 David Honegger
%

if nargin<2
    doOverwrite = true;
end

% xcorrelation parameters
azimuthResolutionFactor = 1/20;    % Resolution factor of search grid (1 if same as input resolution, 1/2 if two gridpoints per input resolution cell, etc.)
minRangeToAnalyze = 400;           % Min range to consider (in pixels)
maxAziToAnalyze = 330/2;           % Max azimuth to consider (in degrees)
dRange = 100;                       % Range decimation of analysis (in pixels)
maxLag = 2;                        % Maximum lag to consider (in degrees)
threshLag = 2;                     % Frames with lags beyond this value don't get adjusted
interpMethod = 'spline';           % For griddedInterpolant.m ... 'linear','spline','nearest', etc.


% Input grid(s)
aziResolution = median(diff(Cube.Azi));
[RG,AZI] = ndgrid(Cube.Rg,Cube.Azi);

% HiRes grid
dAzi = aziResolution*azimuthResolutionFactor;
aziVec = 0:dAzi:360-dAzi;
[hires.RG,hires.AZI] = ndgrid(Cube.Rg,aziVec);

% Output grid: same as input grid: 
dataOut = Cube.data;


% Choose control frame
maxAziForDiag = 330;
trigSkipDiagnostic = sum(squeeze(mean(diff(Cube.data(:,1:maxAziForDiag/aziResolution,:),[],2))) < 1);
[~,bestFrameIdx] = min(trigSkipDiagnostic);

% Create looping vectors
rotationsToAnalyze = setdiff(1:size(Cube.data,3),bestFrameIdx);
minRange = find(diff(Cube.Rg),1,'first');
rangeIdxToAnalyze = minRangeToAnalyze:dRange:length(Cube.Rg);

% Create control frame
interpFuncXcorr = griddedInterpolant(...
    RG(rangeIdxToAnalyze,:),...
    AZI(rangeIdxToAnalyze,:,:),...
    single(Cube.data(rangeIdxToAnalyze,:,bestFrameIdx)),...
    interpMethod);
controlFrame = interpFuncXcorr(hires.RG(rangeIdxToAnalyze,:),hires.AZI(rangeIdxToAnalyze,:));

% Create offset interpolant
interpFuncOffset = griddedInterpolant(...
    RG(minRange:end,:),...
    AZI(minRange:end,:),...
    single(Cube.data(minRange:end,:,bestFrameIdx)),...
    interpMethod);


headingOffset = zeros(size(Cube.data,3),1);

% Loop thru rotations (first is redundant)
for iRot = rotationsToAnalyze
    
    % Interp this rotation to hires azi grid
    interpFuncXcorr.Values = single(Cube.data(rangeIdxToAnalyze,:,iRot));
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
    headingOffset(iRot) = lags(find(rMean==max(rMean),1,'first'))*dAzi;
    
    
    fprintf('Rotation %.f: ',iRot)
    % If lag~=0, interpolate test frame to control grid
    if headingOffset(iRot)
        if abs(headingOffset(iRot)) < threshLag
            interpFuncOffset.GridVectors = {Cube.Rg(minRange:end),Cube.Azi + headingOffset(iRot)};
            interpFuncOffset.Values = single(Cube.data(minRange:end,:,iRot));
            dataOut(minRange:end,:,iRot) = uint8(interpFuncOffset(RG(minRange:end,:),AZI(minRange:end,:)));
            fprintf('Shifted by %.2f degrees.\n',headingOffset(iRot))
        else % If lag > threshold, probably a skipped trigger and this process won't help
            fprintf('Rotation %.f: Max lag threshold exceeded.\n',iRot)
        end
    else
        fprintf('No shift.\n')
    end
            
end

Cube.headingOffset = headingOffset;
if doOverwrite
    Cube.data = dataOut;
else
    Cube.dataCoRect = dataOut;
end