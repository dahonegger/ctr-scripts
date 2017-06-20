%% LABEL
saveFilePrefix = 'plumeFront';
savePath = fullfile('C:','Data','CTR','plumeFront');

%% PREP
scrDir = fullfile('C:','Data','CTR','ctr-scripts');
addpath(genpath(scrDir))
doDebug = false;

%% TIDE HOUR INFO
[uTide,dnTide] = railroadBridgeCurrentLocal;
dnMaxEbb = tideHrMaxEbb2dn(0,dnTide,uTide);
    
%% CHOOSE THE TIME SPAN
% Somehow get the cubes needed to run the transect interpolation script:
cubeDir = fullfile('E:','DAQ-data','processed');
% cubeDir = 'C:\Users\radaruser\Desktop\honegger-temp\tmpData-front\';

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Earliest max ebb in June is #45
thisEbbMax = dnMaxEbb(45);
%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(datestr(thisEbbMax))

deltaDn = 30/60/24;
dnVec = (thisEbbMax - 3.5/24)  :  deltaDn  : (thisEbbMax + 3.5/24);

clear cubeNamesAll
tic
for i = 1:length(dnVec)
    cubeNamesAll{i} = cubeNameFromTime(dnVec(i),cubeDir);
end
cubeNamesAll(cellfun(@isempty,cubeNamesAll)) = [];
toc
cubeName = unique(cubeNamesAll);
% files = getFiles(cubeDir);

%% INITIALIZE SPATIAL ARRAYS
sampleTime = datenum([2017 06 09 21 23 41]);
sampleCubeName = cubeNameFromTime(sampleTime,cubeDir);
load(sampleCubeName,'Azi','Rg','results','timeInt','timex');
if ~exist('timex','var') || isempty(timex)
    load(sampleCubeName,'data')
    timex = mean(data,3);
end
% Rectify to x-y
[AZI,RG] = meshgrid(mod(90-Azi-results.heading,360),Rg);
[xrad,yrad] = pol2cart(AZI*pi/180,RG);
xutm = xrad + results.XOrigin;
yutm = yrad + results.YOrigin;
[lat,lon] = UTMtoll(yutm,xutm,18);

% Choose azimuthal swath
aziSwath = 190:.5:345;
aziIdx = interp1(AZI(1,:),1:length(Azi),aziSwath,'nearest');

% Choose range decimation
rgDecim = 5;
rgIdx = 1:5:length(Rg);

% Generate subimage coordinates
subRg  = Rg(rgIdx);
subAzi = Azi(aziIdx);
subLon = lon(rgIdx,aziIdx);
subLat = lat(rgIdx,aziIdx);
subIm  = uint8(timex(rgIdx,aziIdx));

%%% Debug %%%
if doDebug
dbFig(1) = figure;
    hp = pcolor(subLon,subLat,subIm);
        shading flat
        axis image
        colormap(hot)
        caxis([0 220])
        aspectRatio = (max(lon(:))-min(lon(:)))/(max(lat(:))-min(lat(:)));
        daspect([aspectRatio,1,1])
dbFig(2) = figure;
    hp = imagesc(subIm);
        colormap(hot)
        caxis([0 220])
end
%%% /Debug %%%


%% LOOP THRU FILES

itx = 1;
for i = 1:length(cubeName)
    fprintf('%d of %d.',i,length(cubeName))
    load(cubeName{i},'timeInt','timex','header')
    if header.rotations > 64
        fprintf('Long run.Rot:')
        % Deal with long run
        load(cubeName{i},'data')
        fdata = movmean(data,32,3);
        rotTimes = epoch2Matlab(mean(timeInt));
        dnIdx = find(strcmp(cubeName{i},cubeNamesAll(:)));
        rotIdx = interp1(rotTimes(32:end-32),32:header.rotations-32,dnVec(dnIdx),'nearest','extrap');
        rotIdx = unique(rotIdx);
        for j = rotIdx
            fprintf('%d.',j)
            thisFrame = fdata(rgIdx,aziIdx,j);
            testFig = figure('position',[0 0 500 800]);
                imagesc(bfWrapper(double(thisFrame)));
                title('Left click to continue. Right click to reject.')
            [~,~,button] = ginput(1);
            delete(testFig)
            if button==1
                
                thisTime = epoch2Matlab(mean(timeInt(:,j)));
                thisCurve = img2curve(uint8(thisFrame));
                       
                for ip = 1:length(thisCurve.x)
                    thisCurve.lon(ip) = subLon(round(thisCurve.y(ip)),round(thisCurve.x(ip)));
                    thisCurve.lat(ip) = subLat(round(thisCurve.y(ip)),round(thisCurve.x(ip)));
                end
                %%%%%%%%%%%%%

                txNow.dn  = thisTime;
                txNow.lon = thisCurve.lon;
                txNow.lat = thisCurve.lat;

                %%%%%%%%%%%%%

                tx(itx) = txNow;
                itx = itx + 1;
            end
        end
    else
        thisFrame = timex(rgIdx,aziIdx);
        testFig = figure('position',[0 0 500 800]);
            imagesc(bfWrapper(double(thisFrame)));
            title('Left click to continue. Right click to reject.')
        [~,~,button] = ginput(1);
        delete(testFig)
        if button==1
            thisTime = epoch2Matlab(mean(timeInt(:)));
            thisCurve = img2curve(uint8(thisFrame));
                  
            for ip = 1:length(thisCurve.x)
                thisCurve.lon(ip) = subLon(round(thisCurve.y(ip)),round(thisCurve.x(ip)));
                thisCurve.lat(ip) = subLat(round(thisCurve.y(ip)),round(thisCurve.x(ip)));
            end
            %%%%%%%%%%%%%
            
            txNow.dn  = thisTime;
            txNow.lon = thisCurve.lon;
            txNow.lat = thisCurve.lat;
            
            %%%%%%%%%%%%%
            
            tx(itx) = txNow;
            itx = itx + 1;
        end
        
    end
    fprintf('\n')
end

saveName = sprintf('%s_%s_to_%s',saveFilePrefix,datestr(tx(1).dn,'yyyymmddTHHMMSSZ'),datestr(tx(end).dn,'yyyymmddTHHMMSSZ'));
if ~exist(savePath,'dir');mkdir(savePath);end
if exist(fullfile(savePath,saveName),'file');disp('File to save exists. Do so manually.\n');keyboard;end
save(fullfile(savePath,saveName),'-v7.3','-struct','txOut')
fprintf('Front time series saved to: %s\n',fullfile(savePath,saveName))