addpath(genpath('C:\Data\CTR\ctr-scripts'))
doDebug = true;
%% CHOOSE THE TRANSECT
kmzName = 'mission planning whoi 2.kmz';
[whoiTransect, aplTransect, utTransect] = kmz2transects(kmzName);

tx.lats = whoiTransect(1,:);
tx.lons = whoiTransect(2,:);

%% CHOOSE THE TIME SPAN
% Somehow get the cubes needed to run the transect interpolation script:
cubeDir = 'C:\Users\radaruser\Desktop\honegger-temp\tmpData-front\';
files = getFiles(cubeDir);

%% GENERATE TRANSECT STACK
cubeName = [files(1).folder,files(1).name];

load(cubeName,'Rg','Azi','timex','timeInt','results')
if ~exist('timex','var') || isempty(timex)
    load(cubeName,'data')
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

%%% Debug %%%
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
for i = 1:length(files)
    fprintf('%d of %d.',i,length(files))
    load([files(i).folder,files(i).name],'timeInt','timex','header')
    if header.rotations > 64
        fprintf('Long run.Rot:')
        % Deal with long run
        load([files(i).folder,files(i).name],'data')
        fdata = movmean(data,32,3);
        for j = 32:64:header.rotations-32
            fprintf('%d.',j)
            thisFrame = fdata(minRange:end,:,j);
            tx.dnr = [tx.dnr epoch2Matlab(timeInt(1,j))];
            gInt.Values = single(thisFrame');
            tx.I = [tx.I;gInt(tx.azi.tx.rg)];
        end
    else
        tx.dnr = [tx.dnr epoch2Matlab(mean(timeInt(:)))];
        
        gInt.Values = single(timex(minRange:end,:)');
        tx.I = [tx.I;gInt(tx.azi,tx.rg)];
    end
    fprintf('\n')
end

%% PLOT TRANSECT TIMESTACK

stackFig = figure;
    hp = pcolor(tx.s,tx.dnr,bfWrapper(double(tx.Ir)));
        shading interp
        datetick('y','keeplimits')