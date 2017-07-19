%% SCRIPTS
scrDir = '/nfs/depot/cce_u1/haller/shared/honegger/radar/usrs/connecticut/ctr-scripts/';
addpath(genpath(scrDir))

%% CUBES LOCATION
% This is on SMAUG
cubeDir = fullfile('/media','CTR HUB 2','DAQ-data','processed');

%% OUTPUT LOCATION
pngDir = '/nfs/attic/hallerm/RADAR_DATA/CTR/supportData/vesselData/RADAROVERLAYS/2017-06-28/';
if ~exist(pngDir,'dir');mkdir(pngDir);end

%% LOAD GPS
gpsDir = '/nfs/attic/hallerm/RADAR_DATA/CTR/supportData/vesselData/ctr_dawntreader_nav/surfboard_gps/';
gps = load(fullfile(gpsDir,'nav_surfboard.mat'));

gps.dnutc = gps.dn+4/24; % EDT2UTC
gps.dvutc = datevec(gps.dnutc);
%% June 28th

ii = find(gps.dvutc(:,3)==28 & gps.dvutc(:,4)<15);

Cube = stackTimex(cubeDir,gps.dnutc(ii(1)),gps.dnutc(ii(end)),2/60/24);
Cube = cartCube(Cube);
[Cube.lat,Cube.lon] = UTMtoll(Cube.ydom,Cube.xdom,18); % Zone number 18
alpha = (max(Cube.lat(:))-min(Cube.lat(:)))/(max(Cube.lon(:))-min(Cube.lon(:)));

%%
dd = 1;
fig = figure('visible','off');
ax = gca;
    hp = pcolor(Cube.lon(1:dd:end,:),Cube.lat(1:dd:end,:),Cube.data(1:dd:end,:,1));
        shading interp;axis image
        colormap(hot)
        caxis([5 150])
        title(datestr(Cube.dn(1)))
        xlabel('Longitude')
        ylabel('Latitude')
        box on
    set(gca,'dataaspectratio',[1 alpha 1])
    hold on
    hg = plot(gps.lon(ii(1:11)),gps.lat(ii(1:11)),'.-c');
    hn = plot(gps.lon(ii(2)),gps.lat(ii(2)),'ow','markerfacecolor','k','linewidth',1.5);
    
    
%%
for i = 50:2:length(ii)-5
    fprintf('%d of %d\n',i,length(ii))
    
    gpsi = max(1,i-5):min(i+5,length(ii));
    
    [~,radari] = min(abs(Cube.dn-gps.dnutc(ii(i))));
    radari = radari(1);
    hp.CData = Cube.data(1:dd:end,:,radari);
    
    set(hg,'XData',gps.lon(ii(gpsi)),'YData',gps.lat(ii(gpsi)))
    set(hn,'XData',gps.lon(ii(i)),'YData',gps.lat(ii(i)))
    
    gpsStr = sprintf('\\makebox[4in][c]{Surfboard GPS Time: %s EDT}',datestr(gps.dn(ii(i))));
    radStr = sprintf('\\makebox[4in][c]{Radar Time Span: %s - %s}',datestr(Cube.dn(radari)-40/86400-4/24),datestr(Cube.dn(radari)+40/86400-4/24,'HH:MM:SS'));
    title({gpsStr,radStr},'fontsize',12,'interpreter','latex')
    
    ax.XLim = gps.lon(ii(i))+.005*[-1 1];
    ax.YLim = gps.lat(ii(i))+.005*[-1 1]*alpha;
    
    pngName = sprintf('gpsOnRadar-%sEDT.png',datestr(gps.dn(ii(i)),'yyyymmdd-HHMMSS'));
    print(fig,'-dpng','-r300',fullfile(pngDir,pngName))
end
    
%% FRONT CROSSING TIMES
062850
