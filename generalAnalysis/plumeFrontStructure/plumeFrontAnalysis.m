scrDir = fullfile('C:','Data','CTR','ctr-scripts');
addpath(genpath(scrDir))
%%

files = dir(fullfile('plumeFront','*.mat'));
clear ebb
for i = 1:length(files)
    ebb{i} = load(fullfile(files(i).folder,files(i).name));
end

dem = load('/nfs/attic/hallerm/RADAR_DATA/ctr/supportData/bathy/Montauk_DEM_1111/Montauk_ctrZoom.mat');
[dem.N,dem.E] = lltoUTM(dem.lat,dem.lon);
n0 = 4571410;
e0 = 722590;

ndbc = load(fullfile('wind','ndbc44039','ndbc44039.mat'));
windDirectionOffset = 0;%-45;

% ndbc.wstr = stresslp(ndbc.wspd,3.5);
[~,ndbc.wspd] = cdnlp(ndbc.wspd,3.5);
[ndbc.wu,ndbc.wv] = pol2cart((270-ndbc.wdir+windDirectionOffset)*pi/180,ndbc.wspd);

load(fullfile('wind','ctr_armstrong_data_merged.mat'))
arm.dn = dat.time;
arm.wdir = movmean(mean(dat.met.wdir_true,2),60);
arm.wspd = movmean(mean(dat.met.wspd_true,2),60);
% arm.wstr = stresslp(arm.wspd,20);
[arm.wu,arm.wv] = pol2cart((270-arm.wdir+windDirectionOffset)*pi/180,arm.wspd);

fttech = load(fullfile('wind','fttech','fttech_wind5min.mat'));
fttech.wdir = movmean(fttech.wdir,6);
fttech.wspd = movmean(fttech.wspd,6);
% fttech.wstr = stresslp(fttech.wspd,4);
[fttech.wu,fttech.wv] = pol2cart((270-fttech.wdir+windDirectionOffset)*pi/180,fttech.wspd);

[utide.u,utide.dn] = railroadBridgeCurrent;
%% Interp wind to plume times
for i = 1:length(ebb)
    for j = 1:length(ebb{i}.front)
        [ebb{i}.front(j).n,ebb{i}.front(j).e] = lltoUTM(ebb{i}.front(j).lat,ebb{i}.front(j).lon);
        ebb{i}.front(j).nwu = interp1(ndbc.dn,ndbc.wu,ebb{i}.front(j).dn);
        ebb{i}.front(j).nwv = interp1(ndbc.dn,ndbc.wv,ebb{i}.front(j).dn);
        ebb{i}.front(j).awu = interp1(arm.dn,arm.wu,ebb{i}.front(j).dn);
        ebb{i}.front(j).awv = interp1(arm.dn,arm.wv,ebb{i}.front(j).dn);
        ebb{i}.front(j).fwu = interp1(fttech.dn,fttech.wu,ebb{i}.front(j).dn);
        ebb{i}.front(j).fwv = interp1(fttech.dn,fttech.wv,ebb{i}.front(j).dn);
    end
end


%% Load mooring lat-lon
moor = load('C:\Data\CTR\ctr-wind-analysis\moorings\casts_deploy_lisbuoys_065781_20170519_1302.mat');
[moor.north,moor.east] = lltoUTM(moor.latcast,moor.loncast);
moor.dist = hypot(diff(moor.north),diff(moor.east));
% make extendo-line
s = 0:50:5000;
xl = interp1([0 moor.dist],moor.east-e0,s,'linear','extrap');
yl = interp1([0 moor.dist],moor.north-n0,s,'linear','extrap');
anglel = mean(atand(diff(yl)./diff(xl)));

%% Grab front speeds
xp = -6000:50:1000;
yp = -700*ones(size(xp));

xp = xl;
yp = yl;
clear Cx Cy wum wvm wdirstd TideHr DN 
for i = 1:length(ebb)
    try
        fIntCx      = griddedInterpolant(ebb{i}.frontDiffGrd.X'-e0,ebb{i}.frontDiffGrd.Y'-n0,ebb{i}.frontDiffGrd.Cx'.*ebb{i}.frontDiffGrd.mask');
        fIntCy      = griddedInterpolant(ebb{i}.frontDiffGrd.X'-e0,ebb{i}.frontDiffGrd.Y'-n0,ebb{i}.frontDiffGrd.Cy'.*ebb{i}.frontDiffGrd.mask');
        fIntTideHr  = griddedInterpolant(ebb{i}.frontDiffGrd.X'-e0,ebb{i}.frontDiffGrd.Y'-n0,ebb{i}.frontDiffGrd.tideHr'.*ebb{i}.frontDiffGrd.mask');
        fIntDn      = griddedInterpolant(ebb{i}.frontDiffGrd.X'-e0,ebb{i}.frontDiffGrd.Y'-n0,ebb{i}.frontDiffGrd.DN'.*ebb{i}.frontDiffGrd.mask');
        Cx(:,i)     = fIntCx(xp,yp);
        Cy(:,i)     = fIntCy(xp,yp);
        TideHr(:,i) = fIntTideHr(xp,yp);
        DN(:,i)     = fIntDn(xp,yp);
        wum(i)      = nanmean(cat(1,ebb{i}.front(:).nwu));
        wvm(i)      = nanmean(cat(1,ebb{i}.front(:).nwv));
        wdirstd(i)  = nanstd(angle(cat(1,ebb{i}.front(:).nwu)+1i*cat(1,ebb{i}.front(:).nwv))*180/pi);
    catch
        Cx(:,i)     = deal(nan);
        Cy(:,i)     = deal(nan);
        TideHr(:,i) = deal(nan);
        DN(:,i)     = deal(nan);
    end
end

[Cdir,~] = cart2pol(Cx,Cy);
Cdir  = wrapTo360(270-Cdir*180/pi);
C = hypot(Cx,Cy);
wmdir = wrapTo180(270-angle(wum+1i*wvm)*180/pi);
wmspd = hypot(wum,wvm);

WU = interp1(ndbc.dn,ndbc.wu,DN(:));
WU = reshape(WU,size(DN));
WV = interp1(ndbc.dn,ndbc.wv,DN(:));
WV = reshape(WV,size(DN));
WUL = WU.*cosd(anglel) + WV.*sind(anglel);
WVL = -WU.*sind(anglel) + WV.*cosd(anglel);
WU45L = WUL.*cosd(45) + WVL.*sind(45);
WV45L = -WUL.*sind(45) + WVL.*cosd(45);

S = repmat(s(:),1,size(DN,2));

%% Max ebb wrt moorings

awace = load(fullfile('D:','ctr','supportData','mooring','awac_east.mat'));
awace.urh = movmean(nanmean(awace.ur,2),6);
awace.vrh = movmean(nanmean(awace.vr,2),6);
eastTideHr = tideHour(DN(:),awace.dn,awace.urh,false);
eastTideHr = reshape(eastTideHr,size(DN));
awacw = load(fullfile('D:','ctr','supportData','mooring','awac_west.mat'));
awacw.urh = movmean(nanmean(awacw.ur,2),6);
awacw.vrh = movmean(nanmean(awacw.vr,2),6);
westTideHr = tideHour(DN(:),awacw.dn,awacw.urh,false);
westTideHr = reshape(westTideHr,size(DN));

%% Basic contour plots

fig = figure;
fig.Position = [0 0 800 600];
axMap = gca;
axis equal
box on
axMap.XLim = [-5500 5000];
axMap.YLim = [-5500 3000];
hold(axMap,'on')
hbathy = contour(axMap,dem.E-e0,dem.N-n0,dem.Z,[-50:3:0],'color',[.5 .5 .5]);
hcoast = contour(axMap,dem.E-e0,dem.N-n0,dem.Z,[-1 -1],'k','linewidth',2);

% axWind = axes('position',[0.154 0.797 0.232 0.085]);
% box(axWind,'on')
% hold(axWind,'on')
% hzero = plot(axWind,[0 3.5],[0 0],'-','color',[.5 .5 .5]);
% axWind.XLim = [0 3.5];
% axWind.YLim = [-3 3];

i = length(ebb);

for j = 1:length(ebb{i}.front)
    hfront(j) = plot(axMap,ebb{i}.front(j).e-e0,ebb{i}.front(j).n-n0,'-r');
end

xlabel('[m] East of West Jetty')
ylabel('[m] North of West Jetty')

% hwind = quiver(axWind,[ebb{i}.front(:).tideHr],0*[ebb{i}.front(:).tideHr],...
%     [ebb{i}.front(:).awu],[ebb{i}.front(:).awv],'b');

delete(hfront)
% cmap = jet(length(ebb));
for i = 26%1:length(ebb)
    
%     delete(hfront)
    for j = 1:length(ebb{i}.front)
%         hfront(j) = plot(axMap,ebb{i}.front(j).e-e0,ebb{i}.front(j).n-n0,'-','color','b');
        plot(ebb{i}.front(j).e-e0,ebb{i}.front(j).n-n0,'-','color','r','linewidth',1.5);
    end
%     delete(hwind)
%     hwind = quiver(axWind,[ebb{i}.front(:).tideHr],0*[ebb{i}.front(:).tideHr],...
%         [ebb{i}.front(:).awu],[ebb{i}.front(:).awv],'b');
%     
%     title(axMap,datestr(ebb{i}.front(1).dn))
    
%     drawnow;pause
%     title(axMap,i)
%     title(sprintf('%s UTC',datestr(nanmean(cat(1,ebb{i}.front(:).dn)))))
    drawnow
%     pause()
end

%% Plot contours binned by direction

wdirm = wrapTo180(270-angle(wum+1i.*wvm)*180/pi);
wspdm = hypot(wum,wvm);
dirvec = -170:20:170;
for ibin = 1:length(dirvec)
idx = find(abs(wdirm-dirvec(ibin))<10 & wspdm>0.02);
if ~isempty(idx)

fig = figure;
fig.Position = [0 0 800 600];
axMap = gca;
axis equal
box on
axMap.XLim = [-5500 3000];
axMap.YLim = [-5500 1000];
hold(axMap,'on')
hbathy = contour(axMap,dem.E-e0,dem.N-n0,dem.Z,[-50:3:0],'color',[.5 .5 .5]);
hcoast = contour(axMap,dem.E-e0,dem.N-n0,dem.Z,[-1 -1],'k','linewidth',2);

% axWind = axes('position',[0.154 0.797 0.232 0.085]);
% box(axWind,'on')
% hold(axWind,'on')
% hzero = plot(axWind,[0 3.5],[0 0],'-','color',[.5 .5 .5]);
% axWind.XLim = [0 3.5];
% axWind.YLim = [-3 3];

i = length(ebb);
for j = 1:length(ebb{i}.front)
    hfront(j) = plot(axMap,ebb{i}.front(j).e-e0,ebb{i}.front(j).n-n0,'-r');
end

% hwind = quiver(axWind,[ebb{i}.front(:).tideHr],0*[ebb{i}.front(:).tideHr],...
%     [ebb{i}.front(:).awu],[ebb{i}.front(:).awv],'b');

delete(hfront)
% 60 65

cmap = parula(numel(idx));
for k = 1:length(idx)%[45]%1:length(ebb)
    i = idx(k);     
%     delete(hfront)
    for j = 1:length(ebb{i}.front)
        hfront(j) = plot(axMap,ebb{i}.front(j).e-e0,ebb{i}.front(j).n-n0,'-','color',cmap(k,:));
    end
%     delete(hwind)
%     hwind = quiver(axWind,[ebb{i}.front(:).tideHr],0*[ebb{i}.front(:).tideHr],...
%         [ebb{i}.front(:).awu],[ebb{i}.front(:).awv],'b');
%     
%     title(axMap,datestr(ebb{i}.front(1).dn))
    
%     drawnow;pause
    title(axMap,dirvec(ibin))
end

drawnow
end


end

%% Plot contours binned by along-coast (eastward) wind stress

wdirm = wrapTo180(270-angle(wum+1i.*wvm)*180/pi);
wspdm = hypot(wum,wvm);
wuml = wum.*cosd(anglel) + wvm.*sind(anglel);
binvec = -.08:.04:.08;
binwidth = .02;
for ibin = 1:length(binvec)
    idx = find(abs(wuml-binvec(ibin))<binwidth);
if ~isempty(idx)

fig = figure;
fig.Position = [0 0 800 600];
axMap = gca;
axis equal
box on
axMap.XLim = [-5500 3000];
axMap.YLim = [-5500 1000];
hold(axMap,'on')
hbathy = contour(axMap,dem.E-e0,dem.N-n0,dem.Z,[-50:3:0],'color',[.5 .5 .5]);
hcoast = contour(axMap,dem.E-e0,dem.N-n0,dem.Z,[-1 -1],'k','linewidth',2);

% axWind = axes('position',[0.154 0.797 0.232 0.085]);
% box(axWind,'on')
% hold(axWind,'on')
% hzero = plot(axWind,[0 3.5],[0 0],'-','color',[.5 .5 .5]);
% axWind.XLim = [0 3.5];
% axWind.YLim = [-3 3];

i = length(ebb);
for j = 1:length(ebb{i}.front)
    hfront(j) = plot(axMap,ebb{i}.front(j).e-e0,ebb{i}.front(j).n-n0,'-r');
end

% hwind = quiver(axWind,[ebb{i}.front(:).tideHr],0*[ebb{i}.front(:).tideHr],...
%     [ebb{i}.front(:).awu],[ebb{i}.front(:).awv],'b');

delete(hfront)
% 60 65

cmap = jet(numel(idx));
for k = 1:length(idx)%[45]%1:length(ebb)
    i = idx(k);     
%     delete(hfront)
    for j = 1:3:length(ebb{i}.front)
        hfront(j) = plot(axMap,ebb{i}.front(j).e-e0,ebb{i}.front(j).n-n0,'-','color',cmap(k,:));
    end
%     delete(hwind)
%     hwind = quiver(axWind,[ebb{i}.front(:).tideHr],0*[ebb{i}.front(:).tideHr],...
%         [ebb{i}.front(:).awu],[ebb{i}.front(:).awv],'b');
%     
%     title(axMap,datestr(ebb{i}.front(1).dn))
    
%     drawnow;pause
    title(axMap,binvec(ibin))
end

drawnow
end


end
%% Plot contours binned by cross-coast (northward) wind stress

wdirm = wrapTo180(270-angle(wum+1i.*wvm)*180/pi);
wspdm = hypot(wum,wvm);
wuml = wum.*cosd(anglel) + wvm.*sind(anglel);
wvml = -wum.*sind(anglel) + wvm.*cosd(anglel);
binvec = -.08:.04:.08;
binwidth = .02;
for ibin = 1:length(binvec)
    idx = find(abs(wvml-binvec(ibin))<binwidth);
if ~isempty(idx)

fig = figure;
fig.Position = [0 0 800 600];
axMap = gca;
axis equal
box on
axMap.XLim = [-5500 3000];
axMap.YLim = [-5500 1000];
hold(axMap,'on')
hbathy = contour(axMap,dem.E-e0,dem.N-n0,dem.Z,[-50:3:0],'color',[.5 .5 .5]);
hcoast = contour(axMap,dem.E-e0,dem.N-n0,dem.Z,[-1 -1],'k','linewidth',2);

% axWind = axes('position',[0.154 0.797 0.232 0.085]);
% box(axWind,'on')
% hold(axWind,'on')
% hzero = plot(axWind,[0 3.5],[0 0],'-','color',[.5 .5 .5]);
% axWind.XLim = [0 3.5];
% axWind.YLim = [-3 3];

i = length(ebb);
for j = 1:length(ebb{i}.front)
    hfront(j) = plot(axMap,ebb{i}.front(j).e-e0,ebb{i}.front(j).n-n0,'-r');
end

% hwind = quiver(axWind,[ebb{i}.front(:).tideHr],0*[ebb{i}.front(:).tideHr],...
%     [ebb{i}.front(:).awu],[ebb{i}.front(:).awv],'b');

delete(hfront)
% 60 65

cmap = jet(numel(idx));
for k = 1:length(idx)%[45]%1:length(ebb)
    i = idx(k);     
%     delete(hfront)
    for j = 1:3:length(ebb{i}.front)
        hfront(j) = plot(axMap,ebb{i}.front(j).e-e0,ebb{i}.front(j).n-n0,'-','color',cmap(k,:));
    end
%     delete(hwind)
%     hwind = quiver(axWind,[ebb{i}.front(:).tideHr],0*[ebb{i}.front(:).tideHr],...
%         [ebb{i}.front(:).awu],[ebb{i}.front(:).awv],'b');
%     
%     title(axMap,datestr(ebb{i}.front(1).dn))
    
%     drawnow;pause
    title(axMap,binvec(ibin))
end

drawnow
end


end

%% Plot contours of constant tide hour

wuml = wum.*cosd(anglel) + wvm.*sind(anglel);
wvml = -wum.*sind(anglel) + wvm.*cosd(anglel);


cmap = colorcet('D1');
cmapLim = max(abs(wuml));
cmapMap = linspace(-cmapLim,cmapLim,size(cmap,1));

figure
ax(1) = subplot(121);
ax(2) = subplot(122);
[ax(:).Color] = deal([.5 .5 .5]);
hold(ax(1),'on');hold(ax(2),'on')
for itidehr = -1:.5:4
    contour(ax(1),dem.E-e0,dem.N-n0,dem.Z,[-1 -1],'k','linewidth',2);
    contour(ax(2),dem.E-e0,dem.N-n0,dem.Z,[-1 -1],'k','linewidth',2);
    hold(ax(1),'on');hold(ax(2),'on')
    axis(ax(1),'image');axis(ax(2),'image');
    [ax(:).XLim] = deal([-5000 2000]);
    [ax(:).YLim] = deal([-5000 2000]);
    for i = 1:length(ebb)
        try
            r = interp1(cmapMap,cmap(:,1),wuml(i));
            g = interp1(cmapMap,cmap(:,2),wuml(i));
            b = interp1(cmapMap,cmap(:,3),wuml(i));
            contour(ax(1),ebb{i}.frontDiffGrd.X-e0,ebb{i}.frontDiffGrd.Y-n0,ebb{i}.frontDiffGrd.tideHr.*ebb{i}.frontDiffGrd.mask,itidehr*[1 1],'color',[r g b]);
            
            r = interp1(cmapMap,cmap(:,1),wvml(i));
            g = interp1(cmapMap,cmap(:,2),wvml(i));
            b = interp1(cmapMap,cmap(:,3),wvml(i));
            contour(ax(2),ebb{i}.frontDiffGrd.X-e0,ebb{i}.frontDiffGrd.Y-n0,ebb{i}.frontDiffGrd.tideHr.*ebb{i}.frontDiffGrd.mask,itidehr*[1 1],'color',[r g b]);
        end
    end
    drawnow
    title(itidehr)
    pause
    cla(ax(1));cla(ax(2));
end

%% Plot color contours of front speed

for j = 1:length(ebb{i}.frontDiff(j))
    hp(j) = scatter(ebb{i}.frontDiff(j).east-e0,ebb{i}.frontDiff(j).north-n0,...
        10,ebb{i}.frontDiff(j)