scrDir = fullfile('C:','Data','CTR','ctr-scripts');
addpath(genpath(scrDir))

%% FRONT PATH
frontDir = fullfile('C:','Data','CTR','plumeFront');

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
    plot(tideHourAll,dateNumAll,'.r','markersize',20)
    grid on
    box on
    xlabel('Hour from max ebb')
    datetick('y','keeplimits')
    title('Extracted front times')
    
%% Load example image
sourceDir = fullfile('E:','DAQ-data','processed');
sampleTime = datenum([2017 06 09 21 23 41]);
cubeName = cubeNameFromTime(sampleTime,sourceDir);
load(cubeName,'Azi','Rg','results','timeInt','timex');

[AZI,RG] = meshgrid(90-Azi-results.heading,Rg);
[x,y] = pol2cart(AZI*pi/180,RG);
xutm = x + results.XOrigin;
yutm = y + results.YOrigin;
[radLat,radLon] = UTMtoll(yutm,xutm,18);
plotAspectRatio = (max(radLon(:))-min(radLon(:)))/(max(radLat(:))-min(radLat(:)));
radarFig = figure;
    hp = pcolor(radLon,radLat,timex);
        shading interp
        colormap(hot)
        caxis([0 220])
        xlabel('Longitude')
        ylabel('Latitude')
daspect([plotAspectRatio,1,1])

%% Plot all fronts per image
frontFig = copyobj(radarFig,0);
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
hc.Position([2,4]) = [1/3 1/5]; 
ylabel(hc,'Hr since max ebb','color','w')
hold(frontAx,'all')


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
    pause
    delete(hfront)
end



% %% Animation
% animFig = copyobj(radarFig,0);
%     hold on
%     plot(whoi.Lonbox,whoi.Latbox,'-c')
%     plot(apl.Lonbox,apl.Latbox,'-c')
%     plot(ut.Lonbox,ut.Latbox,'-c')
%     for i = 1:length(tideHourGrid) 
%         idx = find(abs(tideHourAll-tideHourGrid(i))<0.125);
% %         idx = intersect(idx,find(dateNumAll<datenum([2017 06 12 0 0 0])));
% %         idx = idx(end-2:end);
%         ax = gca;
%         ax.ColorOrder = parula(length(idx));
%         clear hf labels
%         for j = 1:length(idx)
%             hf(j) = plot(lonAll{idx(j)},latAll{idx(j)},'-','linewidth',1.25);
%             labels{j} = sprintf('%.f tides before lead',diff(tideNumAll([idx(j) idx(end)])));
%         end
%         title(sprintf('%1.2f Hours since max ebb',tideHourGrid(i)))
%         
%         legend(hf,labels)
%     
%         drawnow
%         pause
%         delete(hf)
%     end
