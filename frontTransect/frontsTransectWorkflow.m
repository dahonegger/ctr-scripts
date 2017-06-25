clear all
%% LABEL
transectPrefix = 'whoi';
% savePath = fullfile('C:','Data','CTR','transects');
savePath = fullfile('D:','Data','CTR','transects');

%% PREP
scrDir = fullfile('C:','Data','CTR','ctr-scripts');
addpath(genpath(scrDir))
doDebug = false;

%% CHOOSE THE TRANSECT
kmzName = fullfile(scrDir,'util','missionPlanningWhoi2.kmz');
bufferLength = 3000;
[whoiTransect, aplTransect, utTransect] = kmz2transects(kmzName,bufferLength);
% 
tx.lats = whoiTransect.Lattx;
tx.lons = whoiTransect.Lontx;

% tx.lats = aplTransect.Lattx;
% tx.lons = aplTransect.Lontx;

% tx.lats = utTransect.Lattx;
% tx.lons = utTransect.Lontx;

%% TIDE HOUR INFO
[uTide,dnTide] = railroadBridgeCurrentLocal;
dnMaxEbb = tideHrMaxEbb2dn(0,dnTide,uTide);
    
%% CHOOSE THE TIME SPAN
% Somehow get the cubes needed to run the transect interpolation script:
% cubeDir = fullfile('E:','DAQ-data','processed');

% cubeDir = fullfile('D:','DAQ-data','processed'); % Lenovo path
cubeDir = 'D:\Data\CTR\DAQ-data\processed\'; % Lenovo path


% cubeDir = 'C:\Users\radaruser\Desktop\honegger-temp\tmpData-front\';

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Earliest max ebb in June is #45
<<<<<<< HEAD
thisEbbMax = dnMaxEbb(77);
=======
%%% MOST RECENT PROCESSED: #74 June 22, 6:07 utc 
thisEbbMax = dnMaxEbb(67);
>>>>>>> af77aa92cd1ebab880cb0e852cbd4a3fcedf48c4
%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(datestr(thisEbbMax))

deltaDn = 5/60/24;
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

%% GENERATE TRANSECT STACK
% cubeName = [files(1).folder,files(1).name];

load(cubeName{1},'Rg','Azi','timex','timeInt','results')
if ~exist('timex','var') || isempty(timex)
    load(cubeName{1},'data')
    timex = mean(data,3);
end

%% Rectify to x-y
[AZI,RG] = meshgrid(90-Azi-results.heading,Rg);
[xrad,yrad] = pol2cart(AZI*pi/180,RG);
xutm = xrad + results.XOrigin;
yutm = yrad + results.YOrigin;
[lat,lon] = UTMtoll(yutm,xutm,18);

%%% Debug %%%
if doDebug
dbFig(1) = figure;
    hp = pcolor(lon,lat,timex);
        shading flat
        axis image
        colormap(hot)
        caxis([0 220])
end
%%% /Debug %%%
%% CONVERT LAT-LON TRANSECT TO AZI-R
[tx.northings,tx.eastings] = lltoUTM(tx.lats,tx.lons);
tx.xrad = tx.eastings - results.XOrigin;
tx.yrad = tx.northings - results.YOrigin;
tx.s = hypot(tx.xrad-tx.xrad(1),tx.yrad-tx.yrad(1));
[tx.azi,tx.rg] = cart2pol(tx.xrad,tx.yrad);
tx.azi = mod(90-results.heading - 180/pi*tx.azi,360);

%%% Debug %%%q
if doDebug
dbFig(2) = figure;hold on
    hp = imagesc(Azi,Rg,timex);
        axis xy
        colormap(hot)
        caxis([0 220])
    plot(tx.azi,tx.rg,'.c')
end
%%% /Debug %%%
%% CREATE GRIDDED INTERPOLANT IN AZI-RANGE SPACE
minRange = find(diff(Rg),1,'first');
Rg_grid = Rg(minRange:end);

[AZI_grid,RG_grid] = ndgrid(Azi,Rg_grid);
gInt = griddedInterpolant(AZI_grid,RG_grid,single(timex(minRange:end,:)'));

%% LOOP THRU FILES

tx.Ir = [];%nan(length(files),length(stx));
tx.dnr = [];%nan(length(files),1);
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
            thisFrame = fdata(minRange:end,:,j);
            tx.dnr = [tx.dnr epoch2Matlab(timeInt(1,j))];
            gInt.Values = single(thisFrame');
            tx.Ir = [tx.Ir;gInt(tx.azi,tx.rg)];
        end
    else
        tx.dnr = [tx.dnr epoch2Matlab(mean(timeInt(:)))];
        
        gInt.Values = single(timex(minRange:end,:)');
        tx.Ir = [tx.Ir;gInt(tx.azi,tx.rg)];
    end
    fprintf('\n')
end

%% PLOT TRANSECT TIMESTACK IMAGE

[grd.stx,grd.dnr] = ndgrid(tx.s,tx.dnr);
gInt = griddedInterpolant(grd.stx,grd.dnr,tx.Ir');
[reg.stx,reg.dn] = ndgrid(tx.s,tx.dnr(1):1/60/24:tx.dnr(end));
reg.Ir = gInt(reg.stx,reg.dn)';
reg.stx = reg.stx';
reg.dn = reg.dn';

if doDebug
dbFig(3) = figure;
    imagesc(reg.stx(1,:),reg.dn(:,1),reg.Ir)
    axis xy
    datetick('y','mmm-dd HH:MM','keeplimits')
end

%% APPLY BILATERAL FILTER

reg.IrBf = bfWrapper(double(reg.Ir));

%% USER CLICKS ROI

[mask,reg.xroi,reg.yroi] = roipoly(uint8(reg.IrBf));

%% APPLY FRANGI FILTER

opts.BlackWhite = false;
opts.FrangiScaleRange = [1 5];
opts.FrangiScaleRatio = 3;
[reg.IrBfFr,scale,direction] = FrangiFilter2D(reg.IrBf,opts);

%% LOWPASS FILTER
lowPassSize = [5,1];
hfLowpass = fspecial('average',lowPassSize);
reg.IrBfFrLp = filter2(hfLowpass,reg.IrBfFr);

%% RETURN MAXIMA PER ROW OF MASKED & FILTERED IMG

reg.IrBfFrLpMask = mask.*reg.IrBfFrLp;

stxMaxima = nan(size(reg.IrBfFrLpMask,1),1);
for i = 1:size(reg.IrBfFrLpMask,1)
    if std(reg.IrBfFrLpMask(i,:))>0
        [mm,idx] = max(reg.IrBfFrLpMask(i,:));
        stxMaxima(i) = reg.stx(1,idx);
    else
        stxMaxima(i) = nan;
    end
end
dnMaxima = nan(size(reg.IrBfFrLpMask,2),1);
for i = 1:size(reg.IrBfFrLpMask,2)
    if std(reg.IrBfFrLpMask(:,i))>0
        [mm,idx] = max(reg.IrBfFrLpMask(:,i));
        dnMaxima(i) = reg.dn(idx,1);
    else
        dnMaxima(i) = nan;
    end
end

[stxMaxCat,sIdx] = sort([stxMaxima;reg.stx(1,:)']);
dnMaxCat = [reg.dn(:,1);dnMaxima];
dnMaxCat = dnMaxCat(sIdx);
nanIdx = isnan(stxMaxCat.*dnMaxCat);
stxMaxCat = stxMaxCat(~nanIdx);
dnMaxCat = dnMaxCat(~nanIdx);
maxCat = [stxMaxCat(:) dnMaxCat(:)];
maxCatUnique = unique(maxCat,'rows');
%% SMOOTH RESULTING CURVE TO FILTER OUT NOISE
stxMaxCat = maxCatUnique(:,1);
dnMaxCat = maxCatUnique(:,2);

hampelWidths = [100 50 25 12 6 3];
dnFrontSmooth = dnMaxCat;
for iWidth = hampelWidths
    dnFrontSmooth = hampel(dnFrontSmooth,iWidth);
end
sFrontSmooth = stxMaxCat;
for iWidth = hampelWidths
    sFrontSmooth = hampel(sFrontSmooth,iWidth);
end
dnFrontSmooth = smooth(stxMaxCat,dnFrontSmooth,50,'rlowess');
[dnFrontSmooth,idx] = unique(dnFrontSmooth);
sFrontSmooth = smooth(sFrontSmooth(idx),50,'rlowess');
%% PLOT RESULTING CURVE

outFig = figure;hold on
%     hp = imagesc(reg.stx(1,:),reg.dn(:,1),reg.IrBfFrLpMask);
    hp = imagesc(reg.stx(1,:),reg.dn(:,1),reg.Ir);
    axis xy
    datetick('y','keeplimits')
%     hp = plot(stxMaxima,reg.dn(:,1),'.y');
%     hp = plot(reg.stx(1,:),dnMaxima,'.r');
    hp = plot(stxMaxCat,dnMaxCat,'.r');
    hp = plot(sFrontSmooth,dnFrontSmooth,'.-c');

%% BACK TO RADAR TIMES
tx.sFront = interp1(dnFrontSmooth,sFrontSmooth,tx.dnr,'linear');

% figShow = figure;
%     hp = pcolor(tx.s,tx.dnr,tx.Ir);
%         shading interp
%         colormap(hot)
%         caxis([0 220])
%     hold on
%     hp = plot(tx.sFront,tx.dnr,'.c');
    
%% NOW TWEAK TO MOVE BACK UP TO THE RIDGE

tx.IrBf = bfWrapper(double(tx.Ir),2);
tx.IrBf = filter2(hfLowpass,tx.IrBf);
tx.IrBf = tx.Ir;
tx.sFrontTweak = nan(size(tx.dnr));
for i = 1:length(tx.dnr)
    if ~isnan(tx.sFront(i))
        thisIdx = interp1(tx.s,1:length(tx.s),tx.sFront(i),'nearest');
        thisTx = smooth(tx.s,tx.IrBf(i,:),9);
%         keyboard
        iter = 0;
        while diff(thisTx(thisIdx-1:thisIdx+1),2)>0
            thisSlope = mean(diff(thisTx(thisIdx-1:thisIdx+1)));
            thisIdx = thisIdx + sign(thisSlope);
            iter = iter+1;
            fprintf('Tweak: %s. Iter %.f.\n',datestr(tx.dnr(i)),iter)
        end
        tx.sFrontTweak(i) = tx.s(thisIdx);
        
    else
        tx.sFrontTweak(i) = nan;
    end
end
    
%% PLOT FINAL(?) TRANSECT

figShow = figure;
    hp = pcolor(tx.s,tx.dnr,bfWrapper(double(tx.Ir)));
        shading interp
        colormap(hot)
        caxis([0 220])
    hold on
    hp = plot(tx.sFront,tx.dnr,'.c');
    hp = plot(tx.sFrontTweak,tx.dnr,'.-b');
    
%% PLACE BUFFERED TRANSECT ON GEOGRAPHIC COORDS

txOut.lonFront = interp1(tx.s,tx.lons,tx.sFront);
txOut.latFront = interp1(tx.s,tx.lats,tx.sFront);
txOut.dnFront = tx.dnr;
txOut.txName = transectPrefix;

saveName = sprintf('%s_%s_to_%s',transectPrefix,datestr(txOut.dnFront(1),'yyyymmddTHHMMSSZ'),datestr(txOut.dnFront(end),'yyyymmddTHHMMSSZ'));
if ~exist(savePath,'dir');mkdir(savePath);end
if exist(fullfile(savePath,saveName),'file');disp('File to save exists. Do so manually.\n');keyboard;end
save(fullfile(savePath,saveName),'-v7.3','-struct','txOut')
fprintf('Transect Saved to: %s\n',fullfile(savePath,saveName))