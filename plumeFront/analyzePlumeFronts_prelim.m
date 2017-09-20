scrDir = fullfile('/nfs','depot','cce_u1','haller','shared','honegger','radar','usrs','connecticut','ctr-scripts');
addpath(genpath(scrDir))

%% FRONT PATH
frontDir = fullfile('/media','CTR HUB 2','RADAR PROCESSED DATA','plumeFront');

%% Load
[uTide,dnTide] = railroadBridgeCurrentLocal;
[whoi,apl,ut] = kmz2transects('missionPlanningWhoi2.kmz');


files = dir(fullfile(frontDir,'plumeFront*.mat'));
clear ebb
for i = 1:length(files)
    ebb(i) = load(fullfile(files(i).folder,files(i).name));
end
clear tNum
for i = 1:length(ebb)
    ebb(i).dnv = [ebb(i).front(:).dn];
    [ebb(i).tideHrM,ebb(i).tNum] = tideHourMaxEbb(ebb(i).dnv,dnTide,uTide,true);
    tNum(i) = ebb(i).tNum(1);
    for j = 1:length(ebb(i).front)
        ebb(i).lon{j} = ebb(i).front(j).lon;
        ebb(i).lat{j} = ebb(i).front(j).lat;
    end
end

dateNumAll = [ebb(:).dnv];
tideHourAll = [ebb(:).tideHrM];
tideNumAll = [ebb(:).tNum];
lonAll = [ebb(:).lon];
latAll = [ebb(:).lat];

%% Regular grid
tideHourGrid = -3.5:.25:3.5;

%% Plot order
isEven = mod(tideNumAll,2);

%% Coverage plot
covFig = figure('position',[0 0 1280 200]);
ax = gca;
    plot(tideHourAll,dateNumAll,'.r','markersize',10)
    grid on
    box on
    xlabel('Hour from max ebb')
    datetick('y','keeplimits')
    title('Extracted front times')
    
%% Load example image
sourceDir = fullfile('/media','CTR HUB 2','DAQ-data','processed');
sampleTime = datenum([2017 06 09 21 23 41]);
cubeName = cubeNameFromTime(sampleTime,sourceDir);
load(cubeName,'Azi','Rg','results','timeInt','timex');

[AZI,RG] = meshgrid(90-Azi-results.heading,Rg);
[x,y] = pol2cart(AZI*pi/180,RG);
xutm = x + results.XOrigin;
yutm = y + results.YOrigin;
[radLat,radLon] = UTMtoll(yutm,xutm,18);
plotAspectRatio = (max(radLon(:))-min(radLon(:)))/(max(radLat(:))-min(radLat(:)));
radarFig = figure('visible','off');
    hp = pcolor(radLon,radLat,timex);
        shading interp
        colormap(hot)
        caxis([0 220])
        xlabel('Longitude')
        ylabel('Latitude')
daspect([plotAspectRatio,1,1])

%% Plot all fronts per image
frontFig = copyobj(radarFig,0);
frontFig.Visible = 'on';
frontFig.InvertHardcopy = 'off';
radAx = gca;
hp = radAx.Children(end);
 
frontAx = copyobj(radAx,frontFig);
frontAx.Color = 'none';
axis(frontAx,'off')
delete(frontAx.Children)
hc = colorbar(frontAx,'east');
colormap(frontAx,colorcet('d1'))
caxis(frontAx,[-3.5 3.5])
hc.Color = 'w';
hc.Position([2,4]) = [.35 1/5]; 
ylabel(hc,'Hr since max ebb','color','w')
hold(frontAx,'all')
grid on
    hold on
%     plot(whoi.Lonbox,whoi.Latbox,'-c')
%     plot(apl.Lonbox,apl.Latbox,'-c')
%     plot(ut.Lonbox,ut.Latbox,'-c')


numList = unique(tideNumAll);
for i = 1:length(numList)
    idx = find(tideNumAll==numList(i));
    cubeIdx = find(abs(tideHourAll(idx))==min(abs(tideHourAll(idx))));
    thisDateNum = dateNumAll(idx(cubeIdx));
    cubeName = cubeNameFromTime(thisDateNum(1),sourceDir);
    fprintf('%.f; %f; %s.\n',numList(i),abs(tideHourAll(idx(cubeIdx))),cubeName)
    
    load(cubeName,'timex','timeInt')
    if ~exist('timex','var') || isempty(timex)
        load(cubeName,'data')
        timex = mean(data,3);
        fprintf('NO TIMEX: %s\n',cubeName)
    end
    frontFig.CurrentAxes = radAx;
    cubeTime = mean(epoch2Matlab(timeInt(:)));
    hp.CData = timex;
    timeSinceMaxEbb = tideHourMaxEbb(cubeTime,dnTide,uTide,true);
    title(sprintf('Max ebb: %s UTC (%s EDT)',...
        datestr(cubeTime-timeSinceMaxEbb/24,'yyyy-mmm-dd HH:MM'),...
        datestr(cubeTime-timeSinceMaxEbb/24-4/24,'HH:MM')))
        
    clear hfront
    for ifront = 1:length(idx)
        hfront(ifront) = scatter(frontAx,lonAll{idx(ifront)},latAll{idx(ifront)},...
            10,tideHourAll(idx(ifront))*ones(size(lonAll{idx(ifront)})),'filled');
    end
    drawnow
    
    
    print(frontFig,'-dpng','-r300',fullfile(frontDir,sprintf('Ebb_%sUTC.png',datestr(cubeTime-timeSinceMaxEbb/24,'yyyymmddTHHMMSSZ'))))
    
    
    
    delete(hfront)
end



%% Animation
lastTideHour = max(tideNumAll);

animFig = copyobj(radarFig,0);
animFig.Visible = 'on';
    hold on
    plot(whoi.Lonbox,whoi.Latbox,'-c')
    plot(apl.Lonbox,apl.Latbox,'-c')
    plot(ut.Lonbox,ut.Latbox,'-c')
ax = gca;

relVec = -4:2:0; % Relative tide number to lastTideHour
ax.ColorOrder = flipud(summer(length(relVec)));
% ax.LineStyleOrder = {'-','--','-.',':'};
    for i = 4:length(tideHourGrid) 
        idxTideHour = find(abs(tideHourAll-tideHourGrid(i))<0.1);
        idxDay = find(ismember(tideNumAll,lastTideHour+relVec));
        
%         idx = intersect(idx,find(dateNumAll<datenum([2017 06 12 0 0 0])));
        
        idx = intersect(idxTideHour,idxDay);
        
        if ~isempty(idx)
        
            ax.ColorOrderIndex = 1;
            ax.LineStyleOrderIndex = 1;
            
            clear hf labels
            for j = 1:length(idx)
                hf(j) = plot(lonAll{idx(j)},latAll{idx(j)},'-','linewidth',2);
                labels{j} = sprintf('%.f days prior',diff(tideNumAll([idx(j) idx(end)])/2));
            end
            title(sprintf('%1.2f Hours since max ebb',tideHourGrid(i)))

            labels{end} = sprintf('This ebb: %s',datestr(dateNumAll(idx(end))));
            legend(hf,labels)
            
            drawnow
            ginput(1);
            delete(hf)
        end
    end

%% Get time extent of extracted fronts

lastExtractionTime = nan(size(ebb));
lastExtractionTideHr = nan(size(ebb));
distFmRadar = nan(size(ebb));
for i = 1:length(ebb)
    lastExtractionTime(i) = max(ebb(i).dnv);
    lastExtractionTideHr(i) = max(ebb(i).tideHrM);
    lons = (ebb(i).lon{end});
    lats = (ebb(i).lat{end});
    [meanNor,meanEas] = lltoUTM(lats,lons);
    [radNor,radEas] = lltoUTM(41.262664,-72.342817);
    distFmRadar(i) = min(hypot(meanEas-radEas,meanNor-radNor));
end
% Load wind data
[dnWind,vWind,dirWind] = loadWindNDBC('E:\SupportData\Wind\METDATA_NDBC44039.txt');
idx = dnWind==0 | dnWind<datenum([2017 06 01 0 0 0]);
dnWind(idx) = [];
vWind(idx) = [];
dirWind(idx) = [];

[eWind,nWind] = pol2cart((270-dirWind)*pi/180,vWind);

vWindS = smooth(dnWind,vWind,3);
nWindS = smooth(dnWind,nWind,3);
eWindS = smooth(dnWind,eWind,3);
alongCrossWindS = [eWindS(:) nWindS(:)]*[1/2 sqrt(3)/2]';

[dirWindSm,vWindSm] = cart2pol(eWindS,nWindS);
dirWindSm = mod(270-dirWindSm*180/pi,360);

figure
    plot3(...
        interp1(dnWind,dirWindSm,lastExtractionTime),...
        interp1(dnWind,vWindSm,lastExtractionTime),...
        distFmRadar,...
        '.b','markersize',20);
    view(0,0)
    xlabel('Wind Direction [deg]')
    ylabel('Wind Speed [m/s]')
    zlabel('Max Distance from Mouth [m]')
    xlim([0 360])
    zlim([0 6000])

% 
% figure;
%     [ax,h1,h2] = plotyy(...
%         dnWind,smooth(dnWind,nWind,24),...
%         lastExtractionTime,lastExtractionTideHr);
%     hold(ax(1),'on')
%     plot(ax(1),dnWind,0*dnWind,':k')
%     h1.LineStyle = '-';
%     h1.LineWidth = 1.5;
%     h1.Color = 'b';
%     h2.LineStyle = 'none';
%     h2.Marker = 'o';
%     h2.MarkerFaceColor = 'r';
%     h2.Color = 'r';

